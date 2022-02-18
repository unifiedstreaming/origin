#!/bin/bash
docker run -d \
  -e UspLicenseKey=bGljZW5zZUB1bmlmaWVkLXN0cmVhbWluZy5jb218MjAyMjAxMzAgMDA6MDA6MDAsMzY3fHBhY2thZ2UoZGFzaCxobHMsaXNzLGhkcyxtcDQsY21hZik7c3RyZWFtKHZvZCxsaXZlLGluZ2VzdF90cyx2b2QybGl2ZSk7ZHJtKGFlcyxkeGRybSxmYXhzLG1hcmxpbixwbGF5cmVhZHksc2FtcGxlX2Flcyx2ZXJpbWF0cml4X2hscyxpcmRldG9fc2tlLGNvbmF4X3ByX2hscyx3aWRldmluZSxwbGF5cmVhZHlfZW52ZWxvcGUscGhkcyk7aW9fb3B0KDEwMCk7Y2FwdHVyZShobHMsaXNzLGhkcyxkYXNoLGRlY3J5cHQpO3ZlcmlmeShtZWRpYSx1cmxzLHNpdGVtYXApO29lbSgpO3JlbWl4KG5wdnIsdm9kKTtlbmNvZGUoYWFjLGF2YyxoZXZjKTtkZWNvZGUoYWFjLGF2YyxoZXZjKTttZXRhZGF0YSh0aW1lZCk7dmVyc2lvbigxLjExLjEzKXxEZXZlbG9wbWVudHxhN2IxZWRmMmQwNDY0NTUyYjBjNDg0MDgzZWEyMmI1OHxDMzAyMjJBNTA2Qjc4NUMwMUU1NUU3RTk3NEMyNEU4Q0MxRENFNENDM0VBOEM1MUJDODJDMjgyNzQ0OUQwMTYxOTJGNjJGOTdCRTVGNjgxMjVGNDQ5QzQ5RjVCN0I1MTA3NUI0NjAyMTgwMzM0Qjc1NUEzRDlGQjJGMzY1NkFEREY5ODlDMENDODQwQ0M4MEExNkU2MDMyQjgzOTVBN0Y0ODJBNDAwREZDNENCRDE2NUQ4RTUzNDcyRDAzMUFENDBCOUI2MzM1NzIwNDU3ODdCQjk5MkQ3QThDMjEzMkQwNzI2NUI4NjREMUE3NTZCNkM0REZBOUNFQzlDQTFDRTkx \
  -e REMOTE_PATH=usp-s3-storage \
  -e REMOTE_STORAGE_URL=http://usp-s3-storage.s3.eu-central-1.amazonaws.com/ \
  -v ~/git_checkout/origin/manifests:/root/manifests/ \
  -v ~/git_checkout/origin/use-cases:/root/use-cases/ \
  -v ~/git_checkout/origin/tos:/var/www/unified-origin/tos/ \
  -p 80:80 \
  --name manifest_edit \
  unified-streaming/unified-manifest-edit-new:latest
#unifiedstreaming/unified-origin:latest