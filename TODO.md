## TODO planning for p5-Bio-SeqWare-File-Table

# ROADMAP
These changes are planned for the release specified. Date and version indicate when they are expected to be released.

2014-04-15 0.000.002 - Core File IO
   [DEV] - Refactor tests to have one test file per trial input file.

2014-04-16 0.000.003 [API] - Data Access
  - Get header, parsed as array-ref.
  - Get data lines as array-ref, parsed as array-ref.
  - Get data lines as array-ref, parsed as hash-ref, headers as keys.
  - Get canonical field-parsed data structure.
  - Identical with/without EOL on last line.

2014-04-17 0.000.004 [API] - Blanks and Delimiters
  - Allow blank lines.
  - Allow headers with embedded spaces.
  - Allow user-specified field delimiter string.
  - Allow user-specified field delimiter regexp.
  - Allow different delimiter in heading and data.
  - Allow blank line delimiter regexp.
  - Allow other EOL

2014-04-18 0.000.005 [API] - Comments
  - Allow ‘#’ specified comments.
  - Get comment lines as array-ref.
  - Allow user-specified comment delimiter string.
  - Allow user-specified comment delimiter regexp.

2014-04-19 0.000.006 [API] - Comment data access
  - Get comment lines as array-ref of blocks.
  - Get comment block associated with header.
  - Get free (unassociated) comments.
  - Get comment block associated with  following data lines.
  - Get data comments as part of data record.

2014-04-20 0.000.007 [API] - Missing headers
  - Allow user header.
  - Allow no header.

2014-04-21 0.000.008 [API] - Uneven rows
  - Allow uneven data rows if shorter than header.
  - Allow uneven data rows with no header.
  - Allow uneven data rows if longer than header.

# APPROVED / REJECTED
These changes are planned, or will NOT be done, but have not been assigned to a specific future release. Date and version indicate when they were moved from "In consideration". 

# IN CONSIDERATION
These are things we might do. Date and version indicate when they were added for consideration.

