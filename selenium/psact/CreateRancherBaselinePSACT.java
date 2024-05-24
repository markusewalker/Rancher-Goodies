package rancherselenium.psact;

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

public class CreateRancherBaselinePSACT {
	public static String CHROMEDRIVER_PATH = "";
	public static final int TEN_SECONDS = 10;
	public static String EXPECTED_URL = "";
	public static String USERNAME = "";
	public static String PASSWORD = "";
	public static String PSACT_NAME = "rancher-baseline";
	public static String PSACT_DESCRIPTION = "This is a custom baseline Pod Security Admission Configuration Template" +
											 "It defines a minimally restrictive policy which prevents known privilege escalations." +
											 "This policy contains namespace level exemptions for Rancher components.";
	public static String PSACT_NAMESPACES = "ingress-nginx,kube-system,cattle-system,cattle-epinio-system,cattle-fleet-system," + 
											 "cattle-fleet-local-system,longhorn-system,cattle-neuvector-system,cattle-monitoring-system," +
											 "rancher-alerting-drivers,cis-operator-system,cattle-csp-adapter-system,cattle-externalip-system," +
											 "cattle-gatekeeper-system,istio-system,cattle-istio-system,cattle-logging-system,cattle-windows-gmsa-system,"+
											 "cattle-sriov-system,cattle-ui-plugin-system,tigera-operator,cattle-provisioning-capi-system";
	
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
	
	@Test(priority=1, alwaysRun=true, description="Navigate to PSACT page")
	public void navigateToPSACT() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/provisioning.cattle.io.cluster\"]")));
		
		search = driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/provisioning.cattle.io.cluster\"]"));
		search.click();
		
		String actualURL = driver.getCurrentUrl();
		Assert.assertEquals(EXPECTED_URL+"/dashboard/c/_/manager/provisioning.cattle.io.cluster", actualURL);
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/cloudCredential\"]")));
		
		search = driver.findElement(By.xpath("//*[@id=\"__layout\"]/div/div[1]/nav/div[1]/div[3]/div/h6"));
		search.click();
		
		actualURL = driver.getCurrentUrl();
		Assert.assertEquals(EXPECTED_URL+"/dashboard/c/_/manager/management.cattle.io.podsecurityadmissionconfigurationtemplate", actualURL);
		
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@href=\"/dashboard/c/_/manager/management.cattle.io.podsecurityadmissionconfigurationtemplate/create\"]")));
		
		driver.findElement(By.xpath("//*[@href=\"/dashboard/c/_/manager/management.cattle.io.podsecurityadmissionconfigurationtemplate/create\"]")).click();
	}
	
	@Test(priority=2, alwaysRun=true, description="Create Rancher Baseline PSACT")
	public void createBaselinePSACT() throws Exception {
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//span[contains(text(), 'Create')]")));
		
		String actualURL = driver.getCurrentUrl();
        Assert.assertEquals(EXPECTED_URL+"/dashboard/c/_/manager/management.cattle.io.podsecurityadmissionconfigurationtemplate/create", actualURL);
		
		this.keyboard = new Actions(driver);
		
		keyboard.sendKeys(PSACT_NAME).perform();
		keyboard.sendKeys(Keys.TAB).perform();
		keyboard.sendKeys(PSACT_DESCRIPTION).perform();
		
		driver.findElement(By.xpath("//div[@id='vs1__combobox']/div/span")).click();
		driver.findElement(By.xpath("//li[@id='vs1__option-1']/div")).click();
		driver.findElement(By.xpath("//div[@id='vs2__combobox']/div/span")).click();
		driver.findElement(By.xpath("//li[@id='vs2__option-1']/div")).click();
		driver.findElement(By.xpath("//div[@id='vs3__combobox']/div/span")).click();
		driver.findElement(By.xpath("//li[@id='vs3__option-1']/div")).click();
		
		driver.findElement(By.xpath("//*[@id=\"__layout\"]/div/div[1]/main/div/section/form/div[1]/div[2]/div[6]/span[1]/div/label/span[1]")).click();
		
		keyboard.sendKeys(Keys.TAB).perform();
        keyboard.sendKeys(PSACT_NAMESPACES).perform();
        
        driver.findElement(By.xpath("//*[@id=\"__layout\"]/div/div[1]/main/div/section/form/div[2]/div/button[2]")).click();
        
        Assert.assertTrue(driver.getCurrentUrl().contains(EXPECTED_URL+"/dashboard/c/_/manager/management.cattle.io.podsecurityadmissionconfigurationtemplate"));
	}
	
	@AfterTest
	public void cleanup() throws InterruptedException {
		TimeUnit.SECONDS.sleep(TEN_SECONDS);
		driver.quit();
	}
}
