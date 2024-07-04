# boxMapr 0.1

boxMapr is designed to help labs organise their samples for absolutely no money.

This idea is very much in its infancy. 

So far, `boxMapr` can:

* Accept `.xlsx` files containing box maps of samples. These box maps can be organised in any way the lab deem appropriate. For example, they may organise them by sample type (eg. plasma or PBMCs) or by visit.
* Create an on-screen representation of all the boxes that have been uploaded.
* Prepend sample IDs with a character string if `.xlsx` files have been recorded in shorthand (eg. 21 for A21).
* Label boxes to allow easier reading with a common prefix (eg. Plasma)
* Create a filterable list of samples to help with sample retrieval. 
* Create a table calculating the number of aliquots of each sample (by ID)
* Search for an individual samples within the boxes

Presently, `boxMapr` does not:

* Import and concatenate multiple files
* Allow any data to be exported
* Allow users to update the box maps within the app
* Integrate with a database system like SQL

Other minor things that need to be worked out include:

* Ordering of radio buttons
* Adding a button to allow prepending to all or to only samples which start with numbers
* Adding a logo and generally sprucing up the UI
* Recognising untidy boxes and advising they are consolidated (could this even be done programmatically)
* Supporting boxes which contain less than a single row of samples (this might already work, but it broke my test, so I'm not convinced)
* Adding support for box location within freezers / LN2 tanks

There are some specific formatting instructions for input `.xlsx` files, which I will when I get the chance. 

If you are both a programmer and lab scientist and you see some value in this software, please feel free to help the app to grow. Pull requests are very welcome!

