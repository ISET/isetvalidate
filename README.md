# isetvalidate
In July 2023, we started to (a) remove the validation code and data from individual repositories, and (b) merge them into this repository (isetvalidate).

The advantages of this approach are

  * individual repositories are simpler, so we can focus on just tutorials and scripts.
  * changes to validation scripts, do not show up in the main repo
  * we can share the same validation control scripts across many different repos

The disadvantage is that people who want to create or use validations need to download this additional repo and include it in their path.

By moving the code and data for validation into this repository, we believe we will feel librated to expand the validations, including more testing of the Examples. 

