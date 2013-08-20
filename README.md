# UU (ruby-clever-pastie)

UU is a _secure_ paste webservice aimed at sharing code snippet, shell scripts and pictures.

## Why ?

UU is born after I found out no paste website did support automatic syntax coloring ( http://stackoverflow.com/questions/9465215/pastie-with-api-and-language-detection ).

## Is this secure ?

Not much. I encrypts all pasted text (no image) before sending it to the server with a key that's only available in the javascript runtime. At least, the data cannot be accessed without
the identifier and attached key.

Data is erased after a configurable delay.

## Where can I test it

It's running at http://uu.zoy.org/

## What's next ?

- deletable images
- encrypted images
- rewrite in Golang

## Can I contribute ?

Sure, fork, branch, commit, create a PR. The usual stuff.

You can also contact me @octplane for more information about that.

Thanks for passing by.
