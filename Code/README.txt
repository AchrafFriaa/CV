Computer Vision Challenge Group 29 - Disparity Map
=======================

https://gitlab.lrz.de/cv-challenge-2019-group-29/challenge-cv

What Is This?
-------------
This is a project for Computer Vision course of TUM EI SS 2019.
The provided code calculates a disparity map from a pair of stereo images.
The calculation of the disparity matrix is done by applying simple block matching.
We evaluated our approach and documented it in the file doku-G29.pdf.
The project was written in MATLAB.


HOW TO USE
-----------------------
There are two options to get the resulting disparity map from two images.
They will be described in the following.

Invoke challenge.m
-----------------------

To get the resulting Disparity Map the following steps need to be taken:

1. Specify the Path where your image is residing on your laptop (line 18, challenge.m)
   The Folder specified needs to conatain:
   - A pair of stereo images
   - A ground truth image 'disp0.fm'
   - A file specifiying the camera parameters 'calib.txt' in the format as the samples provided

2. Run challenge.m

3. The result will be:
   R: 				A rotational matrix 
   T:				A translation matrix 
   p: 				The Signal to Noise Ratio between the Disparity Map and the ground truth
   elapsed_time: 	The time the algorithm took to calculate the disparity map

   The resulting values can be read from the command window in MATLAB.

4. The disparity Map will be displayed in a figure, Red corresponds to close objects, Blue corresponds to far objects.

Graphical User Interface
-----------------------



Now you can read the code and its comments and see the result, experiment with
it, and hopefully quickly grasp how things work.

If you find a problem, incorrect comment, obsolete or improper code or such,
please get in contact with us at ga42fuh@mytum.de