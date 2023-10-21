# Rules for validating our dataset.

# First Pass rule validation
pipeline_validation_postExtract <- validator(
    # Ensure uniqueness of cartodb_id and object ids
    ID_uniqueness_satisfyied        = is_unique(cartodb_id,objectid)
    # Ensure requested datetimes are not NA.
  , RequiredData_requested_datetime = !is.na(requested_datetime)
)