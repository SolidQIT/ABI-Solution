# Transaction Fact Table Full Load

**Purpose:**
Apply the Full Load pattern to a Fact Table. The fact table 

**Process:**
```flow
st=>start: Clean Destination Table
op10=>operation: Get Fact Table Data
op20=>operation: Lookup Dimension Ids
op30=>operation: Set Dummy Dimension Members
e=>end: Store into Destination Table

st->op10->op20->op30->e
```

**Description**
Source Fact Table Data contains Business Keys, Measures and additional columns that have to be loaded into the Destination Fact Table. Business Keys must be turned into the related Surrogate Key, buy looking up the Business Key value into the corresponding dimension and taking the Surrogate Key. Only the Surrogate Key will be saved in the fact table, along with the Measures and any additional column that may be needed.

**Additional References**
[Transactional Fact Table](http://todo)
[Business Keys](http://todo)
[Surrogate Key](http://todo)
[Dummy Members](http://todo)

> Written with [StackEdit](https://stackedit.io/).