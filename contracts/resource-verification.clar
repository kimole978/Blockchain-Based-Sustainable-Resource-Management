;; Resource Verification Contract
;; Validates natural assets on the blockchain

(define-data-var admin principal tx-sender)

;; Resource data structure
(define-map resources
  { resource-id: (string-ascii 36) }
  {
    name: (string-ascii 64),
    location: (string-ascii 128),
    type: (string-ascii 32),
    verified: bool,
    verified-by: principal,
    verified-at: uint
  }
)

;; Add a new resource to be verified
(define-public (register-resource (resource-id (string-ascii 36)) (name (string-ascii 64)) (location (string-ascii 128)) (type (string-ascii 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-insert resources
      { resource-id: resource-id }
      {
        name: name,
        location: location,
        type: type,
        verified: false,
        verified-by: tx-sender,
        verified-at: u0
      }
    )
    (ok true)
  )
)

;; Verify a resource
(define-public (verify-resource (resource-id (string-ascii 36)))
  (let ((resource (unwrap! (map-get? resources { resource-id: resource-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set resources
      { resource-id: resource-id }
      (merge resource {
        verified: true,
        verified-by: tx-sender,
        verified-at: block-height
      })
    )
    (ok true)
  )
)

;; Get resource details
(define-read-only (get-resource (resource-id (string-ascii 36)))
  (map-get? resources { resource-id: resource-id })
)

;; Set a new admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
