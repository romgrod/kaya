How to make documentation for Kaya?
==============

Kaya documentation is loaded to your local mongodb during the command `prepare` from all .md files located inside /kaya/documentation/ 
and /kaya/ folders.
Then it's made available in [/kaya/help/main](/kaya/help/main "Help") where you can see all documents and perform searches through them.

Where do i put the documents?
---------------------

You can push them to the kaya git project inside /kaya/documentation/ folder, /kaya/ folder it's also functional but it's discouraged.

What type of file do i use?
---------------------

You can only use Markdown (.md) files.

How do i name it?
---------------------

The name should describe the content of the document, beware that this name its going to be the title of the document in the [/kaya/help/main](/kaya/help/main "Help") page so take that into consideration.
Also all the name should be all in undercase, and words should be separated by "_" wich are replaced by spaces afterwards.

An example of this:

Name of the file:

	this_is_an_example.md

The the title will be like this:

	This is an example

How do i format de content of the file?
---------------------

All files in kaya project shuld be formated like this

	Main title
	==============

	Body of the file

- Main title: it describes the content of the file, it is also the description dispayed here [/kaya/help/main](/kaya/help/main "Help")

- Body of the file: here you can place all the content you want, see ´How do i format de body?´ for more info.


How do i format de body?
---------------------

You can use most of Markdown rules.
Also you can use some basic HTML, but it's strongly discouraged.

Here are some examples:

	Main title
	==============

	Secondary titles
	---------------------

	Normal text.

	> This is a quote.

	*This is italicized*

	**This is bold**

	***This is italicized and bold***

	`this is higlighted`

	- this
	- is a
	- list

	This is a link: [Despegar](http://www.despegar.com/)

	You can make relative links too: [/kaya/help/main](/kaya/help/main "Help")

		 This is a block.

	This is a ruler:

	---------------------------------------


They are displayed as follows:

Main title
==============

Secondary titles
---------------------

Normal text.

> This is a quote.

*This is italicized*

**This is bold**

***This is italicized and bold***

`this is higlighted`

- this
- is a
- list

This is a link: [Despegar](http://www.despegar.com/)

You can make relative links too: [/kaya/help/main](/kaya/help/main "Help")

	This is a block

This is a ruler:

----------------------------------------
