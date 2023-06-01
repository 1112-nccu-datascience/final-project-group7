# [第7組] 多醣辨識
The goals of this project.
在一大堆由質譜儀得到的數據中得到想要的醣類
質譜儀比較重要的數據：[H+]、dMass、dIntensity

原始資料23193筆，從專家知識與化學結構 
可以寫簡單的判斷可以濾掉一定不是的數據
剩下277筆資料中可能有我們要的target
{'F1H3N5',
 'F1H5N4S1',
 'F1H5N4S2',
 'F1H6N4S1_structure1',
 'F1H6N4S2',
 'F1H7N4S2',
 'F2H4N5',
 'F2H6N4S1',
 'F2H7N4G2',
 'F2H7N4S1G1',
 'F2H7N4S2',
 'Not target'}
 這是類別

## Contributors
|組員|系級|學號|工作分配|
|-|-|-|-|
|尤敏米茲夠|社會四|108204019|工作項目| 
|葉佐晨|社會四|108204045|工作項目|
|翁祐祥|資科碩一|111753226|工作項目|
|曾偉綱|資科碩二|108753122|工作項目|
|吳奇峰|資碩工一|111753114|工作項目|


## Quick start
You might provide an example commend or few commends to reproduce your analysis, i.e., the following R script
```R
Rscript code/your_script.R --input data/training --output results/performance.tsv
```

## Folder organization and its related description
idea by Noble WS (2009) [A Quick Guide to Organizing Computational Biology Projects.](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424) PLoS Comput Biol 5(7): e1000424.

### docs
* Your presentation, 1112_DS-FP_groupID.ppt/pptx/pdf (i.e.,1112_DS-FP_group1.ppt), by **06.08**
* Any related document for the project
  * i.e., software user guide

### data
* Input
  * Source
  * Format
  * Size 
* Output

### code
* Analysis steps
* Which method or package do you use? 
  * original packages in the paper
  * additional packages you found

### results
* What is a null model for comparison?
* How do your perform evaluation?
  * Cross-validation, or extra separated data

## References
* Packages you use
* Related publications
