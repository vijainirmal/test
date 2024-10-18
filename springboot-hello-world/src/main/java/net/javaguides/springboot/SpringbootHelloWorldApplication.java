package net.javaguides.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@SpringBootApplication
@RestController
public class SpringbootHelloWorldApplication {

	@GetMapping("/welcome")
	public String welcome(){
		return "Hello World";
	}

	public static void main(String[] args) {
		SpringApplication.run(SpringbootHelloWorldApplication.class, args);
	}

}
