DUET algorithm
==============

MATLAB code that implements the DUET (Degenerate Unmixing Estimation Technique) blind source separation algorithm.

Code is adapted from the Appendix of this publication:

- Rickard, S. (2007). [The DUET Blind Source Separation Algorithm](https://web.archive.org/web/20170513041921/http://www.cs.northwestern.edu/~pardo/courses/casa/papers/DuetSourceSeparationTutorial). In S. Makino, H. Sawada & T.-W. Lee (Eds.), *Blind Speech Separation* (pp. 217-241). Springer. https://doi.org/10.1007/978-1-4020-6479-1_8 (ISBN 978-1-4020-6478-4)

Course webpages:

- [EECS 495-022 Computational Auditory Scene Analysis](https://web.archive.org/web/20180521125513/http://www.cs.northwestern.edu/~pardo/courses/casa/papers.php)
- [University College Dublin](https://web.archive.org/web/20100329094309/http://eleceng.ucd.ie/~srickard/bss.html) (older [Princeton](https://web.archive.org/web/20050212232452/http://www.princeton.edu:80/~srickard/bss.html) version)

The 5-source mixtures audio example files in the [./data](./data/) folder are taken from the above webpages.  They are not the same files or mixing parameters as in the 2007 paper.

There are several variations of DUET.  This version:

- Requires closely-spaced microphones.  It does not include the "Big Delay DUET" methods mentioned in the paper.
- Does not have automatic peak detection. Needs manual identification of peaks in the histogram and number of sources to demix.
- Allows for varying *p* and *q* to emphasize different source characteristics in the histogram. Higher *p* emphasizes time-frequency bins where both signals are strong.  Higher *q* emphasizes higher frequencies.  See p. 225.
- Uses binary masks on the time-frequency points.  T-F points are assigned entirely to only one source. See p. 227 eq. 8.33.
- Uses theoretically optimal weighting of both microphones during reconstruction, instead of masking only one mixture. See p. 227 eq. 8.34.

Use `run_duet.m` to run the algorithm.
