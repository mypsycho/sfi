package com.psycho.test.service;

import org.apache.log4j.Logger;



public class Module1 {
    
    Logger logger = Logger.getLogger(getClass());
    // use log4j

	public void execute1() {
		logger.info("execute1");
	}

	public String execute2() {
	    logger.info("execute2");
		return "hello 2";
	}


}