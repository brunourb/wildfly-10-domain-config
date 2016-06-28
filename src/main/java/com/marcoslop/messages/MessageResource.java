package com.marcoslop.messages;

import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

@Path("/message")
@Produces(MediaType.APPLICATION_JSON)
public class MessageResource {

    @Inject
    MessageService testService;

    @GET
    @Path("/")
    public String getMessageExample(){
        return testService.getMessage();
    }

    @POST
    @Path("/")
    public String getMessageExample(@FormParam("message") String message){
        testService.putMessage(message);
        return "OK";
    }

}
