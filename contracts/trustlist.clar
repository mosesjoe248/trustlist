(define-data-var next-id uint u0)

(define-map providers
  uint
  {
    submitted-by: principal,
    name: (string-utf8 64),
    contact: (string-utf8 64),
    description: (string-utf8 128),
    stake: uint,
    challenged: bool,
    approved: bool
  }
)

(define-map challenges
  uint
  {
    challenger: principal,
    stake: uint,
    votes-for: uint,
    votes-against: uint,
    resolved: bool
  }
)

(define-map votes
  { provider-id: uint, voter: principal }
  { vote-for: bool, amount: uint }
)

;; === Add provider with stake ===
(define-public (submit-provider (name (string-utf8 64)) (contact (string-utf8 64)) (description (string-utf8 128)) (stake uint))
  (begin
    (asserts! (> stake u0) (err u100))
    (let ((id (var-get next-id)))
      ;; Use try! to handle the response from stx-transfer?
      (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
      (map-set providers id {
        submitted-by: tx-sender,
        name: name,
        contact: contact,
        description: description,
        stake: stake,
        challenged: false,
        approved: true
      })
      (var-set next-id (+ id u1))
      (ok id)
    )
  )
)

;; === Challenge a listing ===
(define-public (challenge-provider (id uint) (stake uint))
  (let ((provider (map-get? providers id)))
    (match provider
      provider-data
      (begin
          (asserts! (not (get challenged provider-data)) (err u101))
          (asserts! (> stake u0) (err u102))
          ;; Use try! to handle the response from stx-transfer?
          (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
          (map-set providers id (merge provider-data { challenged: true }))
          (map-set challenges id {
            challenger: tx-sender,
            stake: stake,
            votes-for: u0,
            votes-against: u0,
            resolved: false
          })
          (ok true)
      )
      (err u103)
    )
  )
)

;; === Vote on challenge ===
(define-public (vote (id uint) (vote-for bool) (amount uint))
  (let ((challenge (map-get? challenges id)))
    (match challenge
      data  
        (begin
          (asserts! (not (get resolved data)) (err u104))
          ;; Use try! to handle the response from stx-transfer?
          (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
          (if vote-for
            (map-set challenges id (merge data { votes-for: (+ (get votes-for data) amount) }))
            (map-set challenges id (merge data { votes-against: (+ (get votes-against data) amount) }))
          )
          (map-set votes { provider-id: id, voter: tx-sender } { vote-for: vote-for, amount: amount })
          (ok true)
        )
      (err u105)
    )
  )
)

;; === Resolve vote and update listing ===
(define-public (resolve (id uint))
  (let ((provider (map-get? providers id))
        (challenge (map-get? challenges id)))
    (match provider
      pdata
        (match challenge
          cdata
            (begin
              (asserts! (not (get resolved cdata)) (err u106))
              (map-set challenges id (merge cdata { resolved: true }))
              (if (> (get votes-for cdata) (get votes-against cdata))
                ;; Remove listing: challenger wins
                (begin
                  (map-set providers id (merge pdata { approved: false }))
                  ;; Use try! to handle the response from stx-transfer?
                  (try! (stx-transfer? (+ (get stake cdata) (get stake pdata)) (as-contract tx-sender) (get challenger cdata)))
                )
                ;; Keep listing: provider wins
                ;; Use try! to handle the response from stx-transfer?
                (try! (stx-transfer? (get stake cdata) (as-contract tx-sender) (get submitted-by pdata)))
              )
              (ok true)
            )
          (err u107)
        )
      (err u108)
    )
  )
)

;; === Read-only: get provider ===
(define-read-only (get-provider (id uint))
  (map-get? providers id)
)

;; === Read-only: get all approved ===
(define-read-only (is-approved (id uint))
  (let ((p (map-get? providers id)))
    (match p provider-data
      (ok (get approved provider-data))
      (err u109)
    )
  )
)