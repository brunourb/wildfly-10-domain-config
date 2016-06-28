package com.marcoslop.messages;

import com.marcoslop.cache.Cache;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ejb.Stateless;
import javax.inject.Inject;

@Stateless
public class MessageService {

    private static final Logger logger = LoggerFactory.getLogger(MessageService.class);

    public static final String CACHE_KEY = "message";

    @Inject
    Cache cache;

    public String getMessage(){
        Object prevValue = cache.getValue(CACHE_KEY);
        logger.info("cache value = "+prevValue);
        if (prevValue==null){
            return null;
        }
        return prevValue.toString();
    }

    public void putMessage(String message){
        cache.putValue(CACHE_KEY, message);
        logger.info("cache value set to = "+message);
    }

}