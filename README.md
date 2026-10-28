# Flow dashboard

A static site on `http://flow-dashboard-mnl.s3-website-eu-west-1.amazonaws.com`, served by S3 website hosting from the public bucket `flow-dashboard-mnl`.

The dashboard is served by a simple static `index.html` file, and a `error.html` page.

```
browser ──http──► S3 website endpoint ──► index.html
                           │
                           └── missing file ──► error.html (404)
```

## Upload the site

Go to AWS UI and upload the flow dashboard `index.html` and the error page `error.html`

- Keep the keys exactly `index.html` and `error.html`. The S3 website configuration looks for these names.
