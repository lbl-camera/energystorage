/*
 * Example on how to create a multilabel image interactively
 * 
 * 
 * To make your life easier, label all samples from class 1 then all for class 2  
 * Do you need more than 2 classes? Change the code: param classX, k
----------------
Created by: Dani Ushizima
Modified: Jul 11th 2022
----------------

 */

var separator = File.separator; // it will run on Windows
var inputdir = "/Users/dani/Desktop/tmp/"; 
var outputdir = "/Users/dani/Desktop/tmp/"; 
var filename = "labels.txt";
var saveAsPNG = true;
var nclasses = 2;

macro "Annotate Image [F5]" {
	//setOption("QueueMacros", true); //run in the same thread as the event dispatch 
	//setOption("WaitForCompletion", true);
	//run("Memory & Threads...", "maximum=10667 parallel=1");
	run("Close All");	
	run("Clear Results"); 
	run("ROI Manager..."); roiManager("reset");
	//Setting defaults 
	run("Options...", "iterations=1 black count=1"); //set black background
	run("Colors...", "foreground=white background=black selection=yellow"); //set colors
	run("Display...", " "); //do not use Inverting LUT
	
	//Open image
	ui_initialization()
	imagename = filename;
	win = getTitle();
	setTool("freeline");
	setTool("wand"); run("Wand Tool...", "tolerance=8 mode=Legacy");
	
	classes = newArray(nclasses);
	q = Math.floor(256/(nclasses+1));
	for (i=0; i<nclasses; i++)
	     classes[i] = (i+1)*q;
	          
	prevNrois = 0;
	for (kclasses = 0; kclasses < nclasses; kclasses++) {
		waitForUser(" SELECT samples for class "+kclasses+1+", \n ADD them to ROI Manager \n ONLY then click OK");	
		nrois = roiManager("count") ;
		a1 = newArray(nrois-prevNrois);
		for (i=0; i<a1.length; i++)
		     a1[i] = i + prevNrois;
		roiManager("Select", a1);
		roiManager("Combine");
		run("Create Mask");
		selectWindow("Mask");
		run("Subtract...", "value="+q);
		prevNrois = nrois;
		wait(100);
		selectWindow(win);
	}	
   
    run("Select None");
	getHistogram(values, counts, 256);
	print("---- Summary of annotation ----")
	for (i=0; i<nclasses; i++){
		print("Class " + i + 1 +"= "+  counts[classes[i]] +" points");
	}

	waitForUser("Ready to create mask ?");
	selectWindow("Mask");
	saveAs("png", outputdir + "Annotation" +imagename+ ".png");	
	
}

//------------ Utilities ------------ 
function ui_initialization(){
 //Find out directory, radix, number of images
 Dialog.create("--- Annotation Tool ---");
 Dialog.addMessage("Select an image from the target folder");
 Dialog.show();
 open();//open image win to get attributes of the experiment, including folder location
 inputdir = getInfo("image.directory");
 outputdir = inputdir+"labeled"+separator;
 File.makeDirectory(outputdir);
 FileList = getFileList(inputdir)
 fname = getInfo("image.filename");
 parts=split(fname,".");
 n=lengthOf(parts[0]);
 filename = substring(parts[0],0,n); //radix
 print("\\Clear");
 print("1. Filename:\n" + getTitle()+ " \n"); 
 print("2. Input folder:\n" + inputdir + " \n"); 
 print("3. Output folder:\n" + outputdir+ " \n"); 

 nclasses = 2;
 Dialog.create("--- Annotation Tool ---"); 
 Dialog.addMessage("Enter the number of different classes to consider:\n");
 Dialog.addNumber(" N classes: ",nclasses,2,4,"max="+10);
 Dialog.show();

 nclasses = Dialog.getNumber(); //number of classes/patterns
 print("N classes="+nclasses);
 
}


