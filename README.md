####**This project is the last project of "Assembly Language Design and Programming" in Xiamen University.**

1. Produce VIRUS.exe file first, then Run STGTH.exe (this is for strengthening)
2. Run VIRUS.exe to spread the virus (after running STGTH.exe, virus can't infect VIRUS.exe itself, but still be able to infect all files in current directory)
3. Run KILLING.exe to kill the virus (even if KILLING.exe file has been infected, it will be able to KILL all the virus, included its own)
4. Run DEFEND.exe to defend files from infection, running this will let all files can't run virus code if they have been infected and will kill ITS OWN virus after run the file, and for non-infected file will run OK without any problem

#*PS: Defending in here is not implemented well, but it has already satisfied teacher's requirement. Moreover, when LINK.exe file is infected, there could be a problem, it seems that this is caused by file's size or any possible problem. In conclusion, it still met the requirement from the techer. In my opinion, it reaches at least 98% as what the teacher wanted.*
