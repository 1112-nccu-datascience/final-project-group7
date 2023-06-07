# [第7組] A new tool to interpret glycomic profile of MS spectral data
The goals of this project.
辨識並分類醣質譜儀數據圖  

質譜儀比較重要的數據：[H+]、dMass、dIntensity  

原始資料23193筆，從專家知識與化學結構  
可以寫簡單的判斷可以濾掉一定不是的數據  


剩下277筆資料中可能有我們要的target  
所有類別  

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
 
 
 

## Contributors
|組員|系級|學號|工作分配|
|-|-|-|-|

|尤敏米茲夠|社會四|108204019|工作項目,model| 
|葉佐晨|社會四|108204045|工作項目,model|
|翁祐祥|資科碩一|111753226|工作項目,model|
|曾偉綱|資科碩二|108753122|ppt, rule model, 前處理|
|吳奇峰|資碩工一|111753114|部分文書|



## Quick start
You might provide an example commend or few commends to reproduce your analysis, i.e., the following R script

```R

Rscript code/your_script.R --input data/training --output results/performance.tsv


```

## Folder organization and its related description
idea by  [The Importance of Glycans of Viral and Host Proteins in Enveloped Virus Infection](https://www.frontiersin.org/articles/10.3389/fimmu.2021.638573/full) 

### docs
* Your presentation, 1112_DS-FP_groupID.ppt/pptx/pdf (i.e.,1112_DS-FP_group1.ppt), by **06.08**
* Any related document for the project
  * gly_mass_program230410.pptx
    *這是介紹GLYCANS的資料  
  *
  
  
### data
* Input 
  * Source  
    *output_name_nor_simple.csv  
	*output_name_nor_log.csv  
  * Format  
    * 'entry no', 'MS1scan no', 'MS1Isolation mass', 'MS1monoIsomass', 'chargeState', 'in [H+]', 'MS2 Scan no'...'Structure'
  * Size 
    * 數量*feature
    * raw 23193*25000
	* output_name_nor_simple 277*277
* Output  

### code
* Analysis steps
* Which method or package do you use? 
  * original packages in the paper
  * additional packages you found

### results
* What is a null model for comparison?
  *weka  
* How do your perform evaluation?
  * Cross-validation, f1 score

## References
* Packages you use
* Related publications
