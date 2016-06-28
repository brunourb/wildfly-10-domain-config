package com.marcoslop.cache;

import javax.annotation.Resource;
import javax.ejb.Stateless;

@Stateless
public class Cache {

    /*
    @Resource(lookup = "java:jboss/infinispan/container/server")
    CacheContainer cc;

    Map<String, Object> cache;

    @PostConstruct
    void init() {
        this.cache = cc.getCache();
    }
    */

    @Resource(lookup = "java:jboss/infinispan/cache/server/default")
    org.infinispan.Cache<String, Object> cache;

    public void putValue (String key, Object value){
        cache.put(key, value);
    }

    public Object getValue (String key){
        return cache.get(key);
    }

}
