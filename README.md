# isetvalidate
In July 2023, we started to (a) remove the validation code and data from individual repositories, and (b) merge them into this repository (isetvalidate).

The advantages of this approach are

  * individual repositories are simpler
  * changes to validation scripts, do not require a git push/pull in the main repo
  * we can improve the features of the validation scripts and use them across different repos

The disadvantage is that people who want to create or use validations need to download this additional repo and include it in their path.

By moving the code and data for validation into this repository, we believe we will feel liberated to expand the validations, including more testing of the Examples. 

