"use-strict";

module.exports = 
{ 
    beforeCreate(event) {},

    afterCreate(event) 
    {       
        const { result, params  } = event;

        strapi.log.info("----------------------------");
        strapi.log.debug(result);
        strapi.log.debug(params);
        strapi.log.info("----------------------------");

        // strapi.services.log.create({
        //     model: 'service',
        //     action: 'create',
        //     content: result,
        //     type: 'INFO',
        //     autor: ''
        // });
    },
};