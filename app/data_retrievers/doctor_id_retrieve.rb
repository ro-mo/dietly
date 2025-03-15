class AlboVerificationService
  def verify(albo_id)
    return false if albo_id.blank?

    require "selenium-webdriver"

    # Set up a headless Chrome browser
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")

    driver = Selenium::WebDriver.for :chrome, options: options

    begin
      # Navigate to the search page
      driver.navigate.to "https://www.fnob.it/servizi/elenco-iscritti/"

      # Find and fill the search field
      search_field = driver.find_element(name: "Numero") # Adjust selector as needed
      search_field.send_keys(albo_id)

      # Submit the form
      search_button = driver.find_element(css: "button[type='submit']") # Adjust selector as needed
      search_button.click

      # Wait for results to load
      wait = Selenium::WebDriver::Wait.new(timeout: 10)
      wait.until { driver.find_element(css: ".search-results") }

      # Check if results indicate the ID is valid
      results = driver.find_elements(css: ".biologist-entry")
      is_valid = results.any? || driver.page_source.include?(albo_id)

      Rails.logger.info "Verifica Albo ID #{albo_id}: #{is_valid ? 'Valido' : 'Non valido'}"
      is_valid
    rescue => e
      Rails.logger.error("Errore durante la ricerca sul sito dell'Albo: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      false
    ensure
      driver.quit
    end
  end
end
