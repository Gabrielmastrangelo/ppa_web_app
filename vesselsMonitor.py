#==================Libraries====================
'''
Libraries for web scrapping the data from the PPA website
'''
from selenium import webdriver
import chromedriver_autoinstaller

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import time #Library for creating delays

'''
Libraries for data manipulation
'''
import pandas as pd
import numpy as np
import re

#==================Collecting the Data#==================
'''
- Goes to the PPA Website
- Log-in
- Download the .xls file with the table
- Save it as csv file
'''

# Check if the current version of chromedriver exists
# and if it doesn't exist, download it automatically,
# then add chromedriver to path
chromedriver_autoinstaller.install()

#Desabling some of the options
options = webdriver.ChromeOptions()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
wd = webdriver.Chrome(options=options)

wd.get("https://agent.kleinsystems.com/") #Open the website

print('Open Website')

#Xpaths of the forms for log in
username_xpath = '/html/body/form/table[1]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/div/table/tbody/tr[1]/td[2]/input'
password_xpath = '/html/body/form/table[1]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/div/table/tbody/tr[2]/td[2]/input'

#Data for log in
username = 'Tiger'
password = 'rivtow29'

#Log in
'''
OBS: I do not know why, but when acessing the website by selenium,
you need to log in two times.
'''
for i in range(2):
    #Switch to frame main
    wd.switch_to.frame("main")
    
    #Filling the form
    wd.find_element(By.XPATH, username_xpath).send_keys(username)
    wd.find_element(By.XPATH, password_xpath).send_keys(password)

    #Pressing the log-in
    wd.find_element(By.XPATH, '/html/body/form/table[1]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/table/tbody/tr/td/div/table/tbody/tr[3]/td/input').click()
    
    time.sleep(2) # Sleep for 2 seconds

    #Switch to main frame again
    wd.switch_to.default_content()


#Change for the right frame
wd.switch_to.frame("main")

#Go to the tab that has our data
wd.find_element(By.XPATH, '//*[@id="leftMenu__ctl0_TrafficTD"]').click()

time.sleep(1.5) # Sleep for 3 seconds

#Downloading the table
wd.find_element(By.XPATH, '//*[@id="_ctl4_btnExportToExcel"]').click()

time.sleep(0.5) # Sleep for 3 seconds

print('Downloaded the Table')

#Read the data that we collected
data = pd.read_excel('Agent Current Traffic Report.xls')

#Organizing the column names
cols = list(data.columns)
cols[1] = 'Job PO'
cols[26: 28]= ['Hellicopter from', 'Hellicopter to']
data.columns = cols

#Sorting by the order time
data = data.sort_values(by='Order Time')

#Saving it into the file that R will read
data.to_csv("data.csv")