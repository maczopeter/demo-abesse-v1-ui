if [ "$1" != "dev" ] && [ "$1" != "prod" ]; then
  echo "----- ERR: \$1 should be either 'dev' or 'prod' -----"
  exit 1
fi

if [ -z "${S3_BUCKET}" ]; then
  echo "ERR: S3_BUCKET is not provided"
  exit 1
fi

if [ -z "${CLF_DIST}" ]; then
  echo "ERR: CLF_DIST is not provided"
  exit 1
fi

echo "----- S3 bucket: $S3_BUCKET"
echo "----- CLF_DIST: $CLF_DIST"

if [ ! -d "./dist" ]; then
  echo "ERR: dist directory not found"
  exit 1
fi

cd dist

echo "----- Deploying to S3 bucket: $S3_BUCKET"
aws s3 sync . s3://$S3_BUCKET/ 

echo "----- Setting cache-control to 0"
aws s3 cp index.html s3://$S3_BUCKET/index.html --cache-control max-age=0 

echo "----- Invalidating CloudFront cache"
aws cloudfront create-invalidation --distribution-id $CLF_DIST --paths '/index.html' 