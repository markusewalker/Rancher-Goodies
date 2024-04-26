package rancherselenium;

import java.time.Duration;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.remote.CapabilityType;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import org.testng.annotations.*;			

public class Login {
	WebDriver driver;
	WebDriverWait wait;
	Actions keyboard;
	
	@BeforeTest
	public void setup() throws Exception {
		ChromeOptions options = new ChromeOptions();
		options.addArguments("--ignore-certificate-errors");
		options.setCapability(CapabilityType.ACCEPT_INSECURE_CERTS, true);
		
		System.setProperty("webdriver.chrome.driver", "<replace with path to chromedriver>");
		
		driver = new ChromeDriver(options);
		wait = new WebDriverWait(driver, Duration.ofSeconds(10));
		keyboard = new Actions(driver);

		driver.manage().window().maximize();
		
		String url = "https://<replace with rancher server url>";
		driver.get(url);
	}
	
	@Test(priority=0, alwaysRun=true, description="Login to the Rancher server.")
	public void login() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("username")));
		
		WebElement search = driver.findElement(By.id("username"));
		search.sendKeys("<user>");
		
		search = driver.findElement(By.xpath("//*[@type=\"password\"]"));
		search.sendKeys("<password>");
		search.sendKeys(Keys.ENTER);		
	}
	
	@AfterTest
	public void cleanup() throws InterruptedException {
		TimeUnit.SECONDS.sleep(10);
		driver.quit();
	}
}