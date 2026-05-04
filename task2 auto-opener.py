from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.service import Service as FirefoxService
from webdriver_manager.chrome import ChromeDriverManager


# Chrome (automatic)
def chrome_test():
    driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
    driver.get("https://www.google.com")
    print("Chrome title:", driver.title)
    driver.quit()


# Firefox (manual path)
def firefox_test():
    driver = webdriver.Firefox(service=FirefoxService(executable_path="/opt/homebrew/bin/geckodriver"))
    driver.get("https://www.google.com")
    print("Firefox title:", driver.title)
    driver.quit()


if __name__ == "__main__":
    chrome_test()
    firefox_test()