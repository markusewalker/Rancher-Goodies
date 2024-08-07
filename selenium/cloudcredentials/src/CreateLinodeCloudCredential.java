package rancherselenium.cloudcredentials;

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
import org.testng.Assert;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

public class CreateLinodeCloudCredential {
	public static String CHROMEDRIVER_PATH = "";
	public static final int TEN_SECONDS = 10;
	public static String EXPECTED_URL = "";
	public static String CRED_NAME = "linode-selenium-creds";
	public static String USERNAME = "";
	public static String PASSWORD = "";
	public static String LINODE_TOKEN = "";

	WebDriver driver;
	WebDriverWait wait;
	WebElement search;
	Actions keyboard;
		
	@BeforeTest
	public void setup() throws Exception {
		ChromeOptions options = new ChromeOptions();
		options.addArguments("--ignore-certificate-errors");
		options.setCapability(CapabilityType.ACCEPT_INSECURE_CERTS, true);
		
		System.setProperty("webdriver.chrome.driver", CHROMEDRIVER_PATH);
		
		driver = new ChromeDriver(options);
		wait = new WebDriverWait(driver, Duration.ofSeconds(TEN_SECONDS));

		driver.manage().window().maximize();
		
		driver.get(EXPECTED_URL);		
	}
	
	@Test(priority=0, alwaysRun=true, description="Login to the Rancher server")
	public void login() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("username")));
		
		search = driver.findElement(By.id("username"));
		search.sendKeys(USERNAME);
		
		search = driver.findElement(By.xpath("//*[@type=\"password\"]"));
		search.sendKeys(PASSWORD);
		search.sendKeys(Keys.ENTER);		
		
		String actualTitle = driver.getTitle();
		String expectedTtle = "Rancher";
		
		Assert.assertEquals(expectedTtle, actualTitle);
	}
	
	@Test(priority=1, alwaysRun=true, description="Navigate to cloud credentials page")
	public void navigateToCloudCredential() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/provisioning.cattle.io.cluster\"]")));
		driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/provisioning.cattle.io.cluster\"]")).click();
		
		String actualURL = driver.getCurrentUrl();
		Assert.assertEquals(EXPECTED_URL+"/dashboard/c/_/manager/provisioning.cattle.io.cluster", actualURL);
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential\"]")));
		driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential\"]")).click();
		
		actualURL = driver.getCurrentUrl();
		Assert.assertEquals(EXPECTED_URL+"/dashboard/c/_/manager/cloudCredential", actualURL);
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential/create\"]")));
		driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential/create\"]")).click();
	}
	
	@Test(priority=2, alwaysRun=true, description="Create Linode cloud credential")
	public void createLinodeCloudCredential() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//span[contains(text(), 'Linode')]")));
		driver.findElement(By.xpath("//span[contains(text(), 'Linode')]")).click();
		
		String actualURL = driver.getCurrentUrl();
		Assert.assertEquals(EXPECTED_URL+"/dashboard/c/_/manager/cloudCredential/create?type=linode", actualURL);
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//span[contains(text(), 'Create')]")));
		
		this.keyboard = new Actions(driver);
		
		keyboard.sendKeys(CRED_NAME).perform();
		keyboard.sendKeys(Keys.TAB).perform();
		keyboard.sendKeys(Keys.TAB).perform();
		keyboard.sendKeys(LINODE_TOKEN).perform();
		
		for (int i = 0; i < 3; i++) {
			keyboard.sendKeys(Keys.TAB).perform();
		}
	
		keyboard.sendKeys(Keys.ENTER).perform();
		
        Assert.assertTrue(driver.getCurrentUrl().contains(EXPECTED_URL+"/dashboard/c/_/manager/cloudCredential"));
	}
	
	@AfterTest
	public void cleanup() throws InterruptedException {
		TimeUnit.SECONDS.sleep(TEN_SECONDS);
		driver.quit();
	}
}
