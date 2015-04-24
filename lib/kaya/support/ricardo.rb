require 'selenium-webdriver'

def buscar_en_google palabra
  @browser = Selenium::WebDriver.for :firefox
  @browser.get "http://google.com"
  campo_de_busqueda = @browser.find_element(:id, "q")
  campo_de_busqueda.send_keys("#{palabra}\n")
end

buscar_en_google "curso de automatizacion de pruebas"