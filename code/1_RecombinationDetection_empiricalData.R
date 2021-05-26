### empirical_treelikeness/code/1_TestStatistics_EmpiricalData.R
## R program to apply treelikeness statistics to transcriptomes from empirical data
## BenchmarkAlignments and metadata have CC0 or CCBY licenses and are available here: https://github.com/roblanf/BenchmarkAlignments
## A number of additional software packages are required, specifically:
##     - IQTREE (Nguyen et al 2015) (http://www.iqtree.org/) (need version 2.0 or later)
##     - 3SEQ (Lam et al 2018) (http://mol.ax/software/3seq/)
##     - Splitstree (Huson and Bryant 2006) (http://www.splitstree.org/) (need SplitsTree 4)
# Caitlin Cherryh 2021

##### Step 1: Set file paths and run variables #####
print("set filepaths")
# input_dir         <- the folder(s) containing the empirical data
# input_names       <- set name(s) for the dataset(s)
# best_model_paths  <- set path to file containing the best model of substitution for each loci
# output_dir        <- for collated output and results. This file should contain a folder for each input_name (where the folder name and corresponding input_name are identical)
# maindir           <- "empirical_treelikeness" repository location (github.com/caitlinch/empirical_treelikeness)
# cores_to_use      <- the number of cores to use for parallelisation. 1 for a single core (wholly sequential), or higher if using parallelisation.
# iqtree_num_threads<- specify number of cores for IQ-Tree to use during tree estimation. May be number, or set as "AUTO" for IQ-Tree to choose best number of threads
# exec_folder       <- the folder containing the software executables needed for analysis (3SEQ, PhiPack, GeneConv)
# exec_paths        <- location to each executable within the folder. Attach the names of the executables so the paths can be accessed by name

# Set which datasets you want to run through which analyses
# If do not want to run that part of the analysis, assign empty vector i.e. datasets_to_run <- c()
# If want to run specific datasets through that part of the analysis, assign only those. E.g. if you have datasets "Trees", "Animals" and "Fungi" and
#    want to run only "Trees" and "Fungi": datasets_to_run <- c("Trees", "Fungi")
# If want to run all of the datasets, assign all names i.e. datasets_to_run <- input_names
# create_information_dataframe <- whether to gather information about each dataset required to run further analysis
#                              <- this information includes loci name, best model for each loci, location of alignment for each loci, etc
#                              <- if TRUE, program will collect all these variables in a dataframe and output a .csv containing this dataframe
#                              <- if FALSE, this step will be skipped
# datasets_to_run   <- Out of the input names, select which datasets will have the treelikeness analysis run and the results collated. If running all, set datasets_to_run <- input_names
# datasets_to_collect_trees <- Out of the input names, select which datasets will have the maximum likelihood trees from IQ-Tree collected and saved in a separate folder for easy downloading. 
#                             If saving all, set datasets_to_run <- input_names
# datasets_apply_AU_test <- Out of the input names, which datasets will you apply the AU test (https://doi.org/10.1080/10635150290069913). If running all, set datasets_to_run <- input_names

# If you are running the AU test, you need to include some extra file paths
# If you are running multiple datasets on the AU test, provide a path for each dataset (i.e. AU_output_folder <- c("/path/to/op1", "/path/to/op2")) in the SAME ORDER
#   as the datasets are in `datasets_apply_AU_test`
# AU_test_id <- phrase to include in output .csv file (so you can easily identify it)
# AU_test_loci_csv <- a csv file containing the a column called `loci_name` that contains the list of all loci to test with the AU test
# AU_output_folder <- A folder to put the output from the AU test (IQ-Tree log files, copy of alignment)
# AU_results_folder <- A folder to output the results of the AU test - for each loci, there will be a csv file containing the log likelihood for each tree topology
# three_trees_path <- A file containing the tree topologies to test using the AU test (called three_trees_path because our analysis compared three three topologies)

# # To run this program: delete lines 83 to 183 inclusive, which include Caitlin's paths/variables
# # Uncomment lines 58 to 81 inclusive and fill the following with your own variable names
# input_dir <- ""
# input_names <- ""
# best_model_paths <- ""
# output_dir <- ""
# maindir <- ""
# cores_to_use <- 1
# iqtree_num_threads <- "AUTO"
# # Create a vector with all of the executable file paths using the following lines as a template:
# # exec_folder <- "/path/to/executables/folder/"
# # exec_paths <- c("3seq_executable","PHIPack_executable", "GeneConv_executable)
# # exec_paths <- paste0(exec_folder,exec_paths)
# # names(exec_paths) <- c("3seq","IQTree","SplitsTree")
# # To access a path: exec_paths[["name"]]
# exec_folder <- ""
# exec_paths <- c()
# exec_paths <- paste0(exec_folder, exec_paths)
# create_information_dataframe <- TRUE
# datasets_to_run <- ""
# datasets_to_collate <- ""
# datasets_to_collect_trees <- ""
# datasets_apply_AU_test <- ""
# # If running AU test, add parameters for AU test here 
# AU_test_loci_csv <- ""
# AU_output_folder <- ""
# AU_results_folder <- ""
# three_trees_path <- ""

### Caitlin's paths ###
run_location = "local"

if (run_location == "local"){
  input_dir <- c("/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/01_Data_1KP/alignments/alignments-FAA-masked_genes/",
                 "/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/01_Data_Strassert2021/02_trimAL_Divvier_filtered_genes_only/",
                 "/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/01_Data_Vanderpool2020/1730_Alignments_FINAL/")
  best_model_paths <- c("/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/01_Data_1KP/OKP_loci_bestmodel.txt",
                        NA,
                        NA)
  input_names <- c("1KP", "Strassert2021","Vanderpool2020")
  output_dir <- c("/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/03_output/")
  treedir <- "/Users/caitlincherryh/Documents/Repositories/treelikeness/" # where the treelikeness code is
  maindir <- "/Users/caitlincherryh/Documents/Repositories/empirical_treelikeness/" # where the empirical treelikeness code is
  
  exec_folder <- "/Users/caitlincherryh/Documents/Executables/"
  # Create a vector with all of the executable file paths  in this order: 3SEQ, IQ-Tree, SplitsTree
  # To access a path: exec_paths[["name"]]
  exec_paths <- c("3seq","Phi", "GENECONV_v1.81_unix.source/geneconv","iqtree-2.0-rc1-MacOSX/bin/iqtree")
  exec_paths <- paste0(exec_folder,exec_paths)
  names(exec_paths) <- c("3seq","PHIPack","GeneConv","IQTree")
  
  # set number of cores for parallelisation
  cores_to_use = 1
  iqtree_num_threads = "AUTO"
  
  # Select datasets to run analysis and collect results
  # If do not want to run that part of the analysis, assign empty vector i.e. datasets_to_run <- c()
  # If want to run specific datasets, assign only those. E.g. if you have datasets "Trees", "Animals" and "Fungi" and
  #     want to run only "Trees" and "Fungi": datasets_to_run <- c("Trees", "Fungi")
  # If want to run all of the datasets, assign all names i.e. datasets_to_run <- input_names
  create_information_dataframe <- TRUE
  datasets_to_run <- c("Strassert2021","1KP", "Vanderpool2020")
  datasets_to_collect_trees <- c("Strassert2021","1KP", "Vanderpool2020")
  datasets_apply_AU_test = c()
  
  # Parameters to perform AU test - needed if one or more dataset names included in datasets_apply_AU_test
  AU_test_id <- "ComparisonTrees"
  AU_test_loci_csv <- "/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/04_trees/Vanderpool2020/all_species_trees/all_loci_loci.csv"
  AU_output_folder <- "/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/03_output/Vanderpool2020_ComparisonTrees_AU_tests/"
  AU_results_folder <- "/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/03_output/Vanderpool2020_ComparisonTrees_AU_test_results/"
  three_trees_path <- "/Users/caitlincherryh/Documents/C1_EmpiricalTreelikeness/04_trees/Vanderpool2020/possible_trees/ComparisonTrees_three_possible_topologies.txt"
  
  
} else if (run_location == "macbook"){
  input_dir <- c("/Users/caitlin/Documents/PhD/Ch01/Data_OKP_sample/",
                 "/Users/caitlin/Documents/PhD/Ch01/Data_Strassert_sample/",
                 "/Users/caitlin/Documents/PhD/Ch01/Data_Vanderpool_sample/")
  input_names <- c("1KP", "Strassert2021","Vanderpool2020")
  best_model_paths <- c("/Users/caitlin/Documents/PhD/Ch01/OKP_loci_bestmodel.txt",
                        NA,
                        NA)
  output_dir <- c("/Users/caitlin/Documents/PhD/Ch01/Output/")
  maindir <- "/Users/caitlin/Repositories/empirical_treelikeness/" # location of repository
  
  exec_folder <- "/Users/caitlin/Documents/PhD/Executables/"
  # Create a vector with all of the executable file paths  in this order: 3SEQ, IQ-Tree, SplitsTree
  # To access a path: exec_paths[["name"]]
  exec_paths <- c("3seq","Phi","geneconv/geneconv","iqtree-2.1.3/bin/iqtree2")
  exec_paths <- paste0(exec_folder,exec_paths)
  names(exec_paths) <- c("3seq","PHIPack","GeneConv","IQTree")
  
  # set number of cores for parallelisation
  cores_to_use = 1
  iqtree_num_threads = "AUTO"
  
  # Select datasets to run analysis and collect results
  # If do not want to run that part of the analysis, assign empty vector i.e. datasets_to_run <- c()
  # If want to run specific datasets, assign only those. E.g. if you have datasets "Trees", "Animals" and "Fungi" and
  #     want to run only "Trees" and "Fungi": datasets_to_run <- c("Trees", "Fungi")
  # If want to run all of the datasets, assign all names i.e. datasets_to_run <- input_names
  create_information_dataframe <- TRUE
  datasets_to_run <- c("Vanderpool2020","Strassert2021","1KP")
  datasets_to_collect_trees <- c("Vanderpool2020","Strassert2021","1KP")
  datasets_apply_AU_test = c()
  
} else if (run_location=="server"){
  input_dir <- c("/data/caitlin/empirical_treelikeness/Data_1KP/",
                 "/data/caitlin/empirical_treelikeness/Data_Strassert2021/",
                 "/data/caitlin/empirical_treelikeness/Data_Vanderpool2020/")
  input_names <- c("1KP", "Strassert2021","Vanderpool2020")
  best_model_paths <- c("/data/caitlin/empirical_treelikeness/Data_inputFiles/OKP_loci_bestmodel.txt",
                        NA,
                        NA)
  output_dir <- "/data/caitlin/empirical_treelikeness/Output/"
  maindir <- "/data/caitlin/empirical_treelikeness/" # where the empirical treelikeness repository/folder is 
  
  # Create a vector with all of the executable file paths in this order: 3SEQ, IQ-Tree, SplitsTree
  # To access a path: exec_paths[["name"]]
  exec_paths <- c("/data/caitlin/linux_executables/3seq/3seq","/data/caitlin/linux_executables/iqtree-2.0-rc1-Linux/bin/iqtree","/data/caitlin/splitstree4/SplitsTree")
  names(exec_paths) <- c("3seq","PHIPack","GeneConv","IQTree")
  
  # set number of cores for parallelisation
  cores_to_use = 25
  iqtree_num_threads = "AUTO"
  
  # Select datasets to run analysis and collect results
  create_information_dataframe <- TRUE
  datasets_to_run <- c("Vanderpool2020","Strassert2021","1KP")
  datasets_to_collect_trees <- c("Vanderpool2020","Strassert2021","1KP")
  datasets_apply_AU_test <- c()
}
### End Caitlin's paths ###



##### Step 2: Source packages and files for functions #####
print("opening packages")
library(ape) # analyses of phylogenetics and evolution
library(parallel) # support for parallel computation
library(phangorn) # phylogenetic reconstruction and analysis
library(seqinr) # data analysis and visualisation for biological sequence data
print("sourcing functions")
source(paste0(maindir,"code/func_recombination_detection.R"))
source(paste0(maindir,"code/func_empirical.R"))



##### Step 3: Extract names and locations of loci #####
# Attach the input_names to the input_files and model paths
names(input_dir) <- input_names
names(best_model_paths) <- input_names
# Create a set of output folders
output_dirs <- paste0(output_dir,input_names,"/")
names(output_dirs) <- input_names
for (d in output_dirs){
  if (file.exists(d) == FALSE){
    dir.create(d)
  }
}

if (create_information_dataframe == TRUE){
  ### One Thousand Plants dataset
  # Obtaining the list of file paths from 1KP is the messiest as each alignment in it a separate folder, where the folder's name is the gene number
  # Then, extract the best model for each loci (to feed into IQ-Tree - because we want to use as many of the original paramaters as we can!)
  OKP_paths <- paste0(input_dir[["1KP"]], list.files(input_dir[["1KP"]], recursive = TRUE, full.names = FALSE))
  OKP_names <- list.files(input_dir[["1KP"]], full.names = FALSE)
  if (is.na(best_model_paths[["1KP"]])){
    OKP_model <- rep("MFP", length(OKP_paths))
  } else {
    OKP_model <- model.from.partition.scheme(OKP_names,best_model_paths[["1KP"]],"1KP")
  }
  OKP_allowed_missing_sites <- NA # Don't remove any sequences based on the number of gaps/missing sites 
  
  ### Strassert 2021 dataset
  Strassert2021_paths <- paste0(input_dir[["Strassert2021"]], list.files(input_dir[["Strassert2021"]], full.names = FALSE))
  Strassert2021_names <- gsub(".filtered.ginsi.bmge.merged.fa.divvy.trimal.fas","",basename(Strassert2021_paths))
  if (is.na(best_model_paths[["Strassert2021"]])){
    # no set of models for these loci.
    # Use "-m MFP" in IQ-Tree to automatically set best model - see Strassert et al (2021)
    Strassert2021_model <- rep("MFP", length(Strassert2021_paths))
  }
  Strassert2021_allowed_missing_sites <- NA # Don't remove any sequences based on the number of gaps/missing sites 
  
  ### Vanderpool 2020 dataset
  # Obtaining the list of loci file paths from Vanderpool 2020 is easy -- all the loci are in the same folder
  Vanderpool2020_paths <- paste0(input_dir[["Vanderpool2020"]], list.files(input_dir[["Vanderpool2020"]], full.names = FALSE))
  Vanderpool2020_names <- gsub("_NoNcol.Noambig.fa","",grep(".fa",unlist(strsplit((Vanderpool2020_paths), "/")), value = TRUE))
  if (is.na(best_model_paths[["Vanderpool2020"]])){
    # no set of models for these loci.
    # Use "-m MFP" in IQ-Tree to automatically set best model - see Vanderpool et al (2020)
    Vanderpool2020_model <- rep("MFP", length(Vanderpool2020_paths))
  }
  Vanderpool2020_allowed_missing_sites <- NA # Don't remove any sequences based on the number of gaps/missing sites 
  
  ### Compile datasets into one dataframe
  # Create a dataframe of loci information for all three datasets: loci name, alphabet type, model, dataset, path, output path
  loci_df <- data.frame(loci_name = c(Vanderpool2020_names, Strassert2021_names, OKP_names),
                        alphabet = c(rep("dna", length(Vanderpool2020_paths)), rep("protein", length(Strassert2021_paths)), rep("protein",length(OKP_paths))),
                        best_model = c(Vanderpool2020_model, Strassert2021_model, OKP_model),
                        dataset = c(rep("Vanderpool2020", length(Vanderpool2020_paths)), rep("Strassert2021",length(Strassert2021_paths)), rep("1KP",length(OKP_paths))),
                        loci_path = c(Vanderpool2020_paths, Strassert2021_paths, OKP_paths),
                        output_folder = c(rep(output_dirs[["Vanderpool2020"]], length(Vanderpool2020_paths)), rep(output_dirs[["Strassert2021"]], length(Strassert2021_paths)), rep(output_dirs[["1KP"]],length(OKP_paths))),
                        allowable_proportion_missing_sites = c(rep(Vanderpool2020_allowed_missing_sites, length(Vanderpool2020_paths)),
                                                               rep(Strassert2021_allowed_missing_sites, length(Strassert2021_paths)),
                                                               rep(OKP_allowed_missing_sites,length(OKP_paths))),
                        stringsAsFactors = FALSE)
  
  # output loci_df <- save a record of the input parameters you used!
  loci_df_name <- paste0(output_dir,"empiricalTreelikeness_input_loci_parameters.csv")
  # If the loci_df hasn't been saved, save it now
  if (file.exists(loci_df_name) == FALSE){
    write.csv(loci_df, file = loci_df_name) 
  }
}



##### Step 4: Apply the recombination detection methods  #####
print("run recombination detection methods")
dataset_ids <- which(loci_df$dataset %in% datasets_to_run)
test_dataset_ids <- c(which(loci_df$dataset == "Vanderpool2020")[1:30])
run_list <- lapply(test_dataset_ids, recombination.detection.wrapper, df = loci_df, executable_paths = exec_paths, iqtree_num_threads)
#run_list <- mclapply(dataset_ids, recombination.detection.wrapper, df = loci_df, executable_paths = exec_paths, iqtree_num_threads, mc.cores = cores_to_use)
run_df <- as.data.frame(do.call(rbind, run_list))
results_file <- paste0(output_dir,"empiricalTreelikeness_",dataset,"_collated_results_",format(Sys.time(), "%Y%m%d"),".csv")
write.csv(run_df, file = results_file, row.names = FALSE)



##### Step 5: Collate trees #####
print("collate trees")
# Check if there are any trees to collate
if (length(datasets_to_collect_trees) > 0){
  # Iterate through each dataset
  for (dataset in datasets_to_collect_trees){
    # Create output folder path for trees and create folder if it doesn't exist
    op_tree_folder <- paste0(output_dir,dataset,"_trees/")
    if (!dir.exists(op_tree_folder)){
      dir.create(op_tree_folder)
    }
    # Start by getting each loci folder
    all_ds_folder <- paste0(output_dirs[[dataset]], list.dirs(output_dirs[[dataset]], recursive = FALSE, full.names = FALSE))
    # Want to go through each loci folder and save tree into op_tree_folder
    lapply(all_ds_folder, save.tree, trees_folder = op_tree_folder)
  }
}



##### Step 6: Apply the AU test to each locus #####
# Run the AU test
if (length(datasets_apply_AU_test) > 0){
  # Assign each variable names based on which datasets will be run
  names(AU_test_loci_csv) <- datasets_apply_AU_test
  names(AU_output_folder) <- datasets_apply_AU_test
  names(AU_results_folder) <- datasets_apply_AU_test
  names(three_trees_path) <- datasets_apply_AU_test
  # Now, iterate through the datasets
  for (dataset in datasets_apply_AU_test){
    for (id in AU_test_id){
      # Open the AU_test_loci_csv
      AU_test_df <- read.csv(AU_test_loci_csv[dataset], stringsAsFactors = FALSE)
      # Get all loci from this file
      loci_names <- AU_test_df$loci_name
      # Get the directory containing the loci for this dataset from the input_dir object
      data_folder <- input_dir[dataset]
      # Run the analysis on all of those files
      # Note that we can't run the analysis on ALL files - because the tree we provided has 29 tips
      # We would have to selectively drop tips and input the file again for each locus with a different set of tips
      lapply(loci_names, perform.AU.test, data_folder, AU_output_folder[dataset], AU_results_folder[dataset], three_trees_path[dataset], exec_paths[["IQTree"]])
      # Read in all the csv files and combine them
      all_AU_csvs <- paste0(AU_results_folder[dataset],list.files(AU_results_folder[dataset]))
      all_csvs <- lapply(all_AU_csvs, read.csv, stringsAsFactors = FALSE, row.names = 1)
      AU_df <- as.data.frame(do.call(rbind, all_csvs))
      AU_df_name <- paste0(output_dirs[dataset], dataset, "_", AU_test_id,"_AU_test_collated.csv")
      write.csv(AU_df, file = AU_df_name)
    }
  }
}



