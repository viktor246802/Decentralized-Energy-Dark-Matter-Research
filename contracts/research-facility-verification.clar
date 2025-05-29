;; Research Facility Verification Contract
;; Validates dark matter energy research facilities

(define-data-var admin principal tx-sender)

;; Map to store verified research facilities
(define-map verified-facilities principal
  {
    name: (string-utf8 100),
    verification-date: uint,
    credentials: (string-utf8 100),
    active: bool
  }
)

;; Public function to verify a new research facility
(define-public (verify-facility
    (facility-address principal)
    (facility-name (string-utf8 100))
    (facility-credentials (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1000))
    (asserts! (is-none (map-get? verified-facilities facility-address)) (err u1001))
    (ok (map-set verified-facilities facility-address
      {
        name: facility-name,
        verification-date: block-height,
        credentials: facility-credentials,
        active: true
      }))
  )
)

;; Public function to revoke verification
(define-public (revoke-verification (facility-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1000))
    (asserts! (is-some (map-get? verified-facilities facility-address)) (err u1002))
    (ok (map-set verified-facilities facility-address
      (merge (unwrap-panic (map-get? verified-facilities facility-address))
             { active: false })))
  )
)

;; Read-only function to check if a facility is verified
(define-read-only (is-verified (facility-address principal))
  (match (map-get? verified-facilities facility-address)
    facility (is-eq (get active facility) true)
    false
  )
)

;; Read-only function to get facility details
(define-read-only (get-facility-details (facility-address principal))
  (map-get? verified-facilities facility-address)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1000))
    (ok (var-set admin new-admin))
  )
)
