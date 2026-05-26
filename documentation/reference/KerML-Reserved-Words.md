# KerML Reserved Words

## Extract from KerML version 1.0 01/09/25

**8.2.2.6 Reserved Words**

A reserved keyword is a token that has the lexical structure of a basic name but cannot actually be used as a basic name. The following keywords are so reserved in KerML.

> about abstract alias all and as assoc behavior binding bool by chains class classifier comment composite conjugate conjugates conjugation connector const crosses datatype default dependency derived differences disjoining disjoint doc else end expr false feature featured featuring filter first flow for from function hastype if implies import in inout interaction intersects inv inverse inverting istype language library locale member meta metaclass metadata multiplicity namespace nonunique not null of or ordered out package portion predicate private protected public redefines redefinition references rep return specialization specializes standard step struct subclassifier subset subsets subtype succession then to true type typed typing unions var xor

Tooling for the KerML textual notation should generally highlight keywords relative to other text, for example by using boldface and/or distinctive coloring. However, while keywords are shown in boldface in this specification, the specification does not require any specific highlighting (or any highlighting at all), and KerML textual notation documents are expected to be interchanged as plain text.