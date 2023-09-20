# isetvalidate
In July 2023, we started to (a) remove the validation code and data from individual repositories, and (b) merge them into this repository (isetvalidate).

The advantages of this approach are

  * individual repositories are simpler
  * changes to validation scripts, do not require a git push/pull in the main repo
  * we can improve the features of the validation scripts and use them across different repos

The disadvantage is that people who want to create or use validations need to download this additional repo and include it in their path.

By moving the code and data for validation into this repository, we believe we will feel liberated to expand the validations, including more testing of the Examples. 

ISETBIOORIG -  Validation scripts from the master branch prior to the ISETBio/ISETCam integration. These were only slightly modified by DHB to simplify the validation.  For example, we no longer check every element of every structure because we know those have changed.  So we validate the numerical data (key properties).  If the photons match at the end, we are good.  

These run when you are on the master branch of ISETBio, without including ISETCam.  They all pass.  The command is

    ieValidateFullAll

DHB to fill in details and perhaps make run with a command like ieValidate('isetbioorig');  
In this directory, the validations are all of the form v_XXX

ISETBIO - These are for the ISETBio/ISETCam configuration. The validation scripts have been renamed to v_ibio_XXX.

Validation data - each of the directories has its own validation data matching the script name.  For example, vf_Colorimetry_Full... and v_ibio_Colorimetry_Full... 
  The total size of these files is about 500 MB, and the largest is 65 MB.
  DHB has them in a dropbox folder.  
  We are about to put them into isetvalidatedata for sharing and updating.

