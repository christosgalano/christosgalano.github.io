#!/bin/bash

cd ../..

sed -i "s/giscus_repo_id_placeholder/$1/" _config.yml
sed -i "s/giscus_category_id_placeholder/$2/" _config.yml
sed -i "s/google_gtag_tracking_id_placeholder/$3/" _config.yml
