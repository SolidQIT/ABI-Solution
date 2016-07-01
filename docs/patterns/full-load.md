# Full Load

**Purpose:**
Load a table from scratch

**Process:**
![Alt text](http://g.gravizo.com/g?
  @startuml;

  %28*%29 --> "First Activity";
  "First Activity" --> %28*%29;
  
  @enduml
)

**Description**
Source Fact Table Data contains Business Keys, Measures and additional columns that have to be loaded into the Destination Fact Table. Business Keys must be turned into the related Surrogate Key, by looking up the Business Key value into the corresponding dimension and taking the Surrogate Key. Only the Surrogate Key will be saved in the fact table, along with the Measures and any additional column that may be needed.

**Additional References**
None
