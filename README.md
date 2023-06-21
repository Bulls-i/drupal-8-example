# drupal-8-example
The example code for the drupal installation on our Drupal Blueprint
This repository can forked. All neccesary secrets need to be set, this is following:

- ECR_URI
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

The resulting image uri can be used during a new blueprint deployment.
In the current version (v1.0) the drupal workdir is expected to be /var/www/html/drupal/