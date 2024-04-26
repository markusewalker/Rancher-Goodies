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
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

public class CreateAmazonCloudCredential {
	WebDriver driver;
	WebDriverWait wait;
	WebElement search;
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
	
	@Test(priority=0, alwaysRun=true, description="Login to the Rancher server")
	public void login() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("username")));
		
		search = driver.findElement(By.id("username"));
		search.sendKeys("<user>");
		
		search = driver.findElement(By.xpath("//*[@type=\"password\"]"));
		search.sendKeys("<password>");
		search.sendKeys(Keys.ENTER);		
	}
	
	@Test(priority=1, alwaysRun=true, description="Navigate to cloud credentials page")
	public void navigateToCloudCredential() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/provisioning.cattle.io.cluster\"]")));
		
		search = driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/provisioning.cattle.io.cluster\"]"));
		search.click();
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential\"]")));
		
		search = driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential\"]"));
		search.click();
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential/create\"]")));
		
		search = driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential/create\"]"));
		search.click();
	}
	
	@Test(priority=2, alwaysRun=true, description="Create Amazon cloud credential")
	public void createAmazonCloudCredential() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//span[contains(text(), 'Amazon')]")));
		
		search = driver.findElement(By.xpath("//span[contains(text(), 'Amazon')]"));
		search.click();
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//span[contains(text(), 'Create')]")));
		
		keyboard.sendKeys("amazon-selenium-creds").perform();
		
		for (int i = 0; i < 22; i++) {
			keyboard.sendKeys(Keys.TAB).perform();
		}
		
		keyboard.sendKeys("<replace with access key>").perform();
		
		keyboard.sendKeys(Keys.TAB);
		keyboard.sendKeys("<replace with secret key").perform();
		
		driver.findElement(By.xpath("//*[@id=\"__layout\"]/div/div[1]/main/div/form/section/form/div[2]/div/button/span")).click();
	}
	
	@AfterTest
	public void cleanup() throws InterruptedException {
		TimeUnit.SECONDS.sleep(10);
		driver.quit();
	}
}
