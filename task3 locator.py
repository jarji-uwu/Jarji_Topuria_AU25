from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.relative_locator import locate_with
import time

driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
driver.get("https://phptravels.com/demo/")

time.sleep(5)

# ===== GRAB ELEMENTS GENERICALLY =====
inputs = driver.find_elements(By.TAG_NAME, "input")
button = driver.find_element(By.TAG_NAME, "button")

# Just pick some inputs (they exist for sure)
first = inputs[0]
last = inputs[1] if len(inputs) > 1 else inputs[0]

# ===== RELATIVE LOCATORS =====
driver.find_element(locate_with(By.TAG_NAME, "input").above(last))
driver.find_element(locate_with(By.TAG_NAME, "button").below(first))

print("All locators passed")

print("Found elements:", len(inputs))
driver.quit()
