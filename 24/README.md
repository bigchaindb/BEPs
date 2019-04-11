```
shortname: BEP-24
name: How to handle ALL pull requests
type: Meta
status: Draft
editor: Troy McConaghy <troy@bigchaindb.com>
```

# Note

BEP-24 replaced [BEP-16](../16).

# Abstract

This BEP says what a BigchainDB repository maintaner (i.e. someone with the ability to merge pull requests) must do when a pull request is submitted to any BigchainDB repository by anyone. Non-maintainers may also read it to find out what they should expect.

This BEP only covers the process for ensuring that contributions are licensed properly. It doesn't cover other aspects of pull request review.

# What to do

If you're a BigchainDB repository maintainer, you must find another maintainer to do this process for _your_ pull requests. You must never merge your own pull requests.

**Note: Copy the raw Markdown source of the following text, not the rendered HTML, because GitHub comments are written in Markdown.**

BEGIN TEXT BLOCK

Before we can merge this pull request, we need you to sign off on licensing your code under the [Apache License version 2.0](https://www.apache.org/licenses/LICENSE-2.0). One of the big concerns for people using and developing open source software is that someone who contributed to the code might claim the code infringes on their copyright or patent. To guard against this, we ask all our contributors to take certain steps (detailed below). This gives us the right to use the code contributed and any patents the contribution relies on. It also gives us and our users comfort that they won't be sued for using open source software. We know it's a hassle, but it makes the project more reliable in the long run. Thank you for your understanding and your contribution!

1. Make sure that every file you modified or created contains a copyright notice comment like the following (at the top of the file):

   ```text
   # Copyright BigchainDB GmbH and BigchainDB contributors
   # SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
   # Code is Apache-2.0 and docs are CC-BY-4.0
   ```

   - If a copyright notice is not present, then add one.
   - If the first line of the file is a line beginning with `#!` (e.g. `#!/usr/bin/python3`) then leave that as the first line and add the copyright notice afterwards.
   - If a copyright notice is present but it says something different, then please change it to say the above.
   - Make sure you're using the correct syntax for comments (which varies from language to language). The example shown above is for a Python file.
1. Read the [Developer Certificate of Origin, Version 1.1](https://developercertificate.org/).
1. You will be asked to include a Signed-off-by line in all your commit messages. (Instructions are given in the next step.) Make sure you understand that including a Signed-off-by line in your commits certifies that you can make the statements in the Developer Certificate of Origin. If you have questions about this, then please ask them in the comments below. Do not continue until you fully understand.
1. Make sure that every commit message in this pull request includes a Signed-off-by line of the form:

   ```text
   Signed-off-by: Random J Developer <random@developer.example.org>
   ```

   with your real name and your real email address. Sorry, no pseudonyms or anonymous contributions. Tip: You can tell Git to include a Signed-off-by line in a commit message by using `git commit --signoff` or `git commit -s`. If you didn't include a Signed-off-by line in your commits so far, you have several options. Probably the simplest is to close this pull request on GitHub, then on your local machine [do an interactive rebase of the last n commits](https://help.github.com/en/articles/changing-a-commit-message) (e.g. the last 3 commits, if your pull request contains 3 commits), then rename your local Git branch (`git branch -m <new-name>`), then push the newly-named branch to GitHub to create a new pull request.

END TEXT BLOCK

Wait for them to fulfill all the above-listed requirements.

Do some checking to convince yourself that each Signed-off-by line contains a real name and email address.

If (and only if) all the above-listed conditions are met, then you can merge the pull request.

# Credits

The Developer Certificate of Origin was developed by the Linux community and has since been adopted by other projects, including many under the Linux Foundation umbrella (e.g. Hyperledger Fabric). The process described above (with the Signed-off-by line in Git commits) is also based on [the process used by the Linux community](https://github.com/torvalds/linux/blob/master/Documentation/process/submitting-patches.rst#11-sign-your-work---the-developers-certificate-of-origin).

# Copyright Waiver

<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law, all contributors to this BEP
  have waived all copyright and related or neighboring rights to this BEP.
</p>
