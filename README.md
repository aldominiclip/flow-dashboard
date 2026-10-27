# Flow dashboard

A static site on `https://flow-dashboard.shared.mnl.miniclip.com`, served from a private S3 bucket.

The dashboard is served by a simple static `index.html` file, and a `error.html` page.

```
browser ──► Route 53 ──► CloudFront (HTTPS, no cache) ──► S3 bucket
                                   │
                                   └── missing file ──► error.html (404)
```

## Upload the site

Go to AWS UI and upload the flow dashboard `index.html` and the error page `error.html`

- Keep the keys exactly `index.html` and `error.html`. CloudFront looks for these names.
