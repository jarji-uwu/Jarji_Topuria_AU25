from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

options = Options()
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--start-maximized")

driver = webdriver.Chrome(
    service=ChromeService(ChromeDriverManager().install()),
    options=options
)

# ===== IMPLICIT WAIT =====
driver.implicitly_wait(5)

# 1. Open Google
driver.get("https://www.google.com")

# Accept cookies if needed
try:
    driver.find_element(By.XPATH, "//button[contains(., 'Accept')]").click()
except:
    pass

# 2. Search Selenium (simulate real typing)
search = driver.find_element(By.NAME, "q")
search.send_keys("Selenium\n")

# ===== EXPLICIT WAIT =====
wait = WebDriverWait(driver, 10)

# 3. Click first result (more stable selector)
first_result = wait.until(
    EC.element_to_be_clickable((By.CSS_SELECTOR, "h3"))
)
first_result.click()

print("Opened first result successfully")

driver.quit()
