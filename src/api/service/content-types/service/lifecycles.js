module.exports = 
{ 
    beforeCreate(event) {},

    afterCreate(event) 
    {       
        const { result, params  } = event;
        strapi.log.debug("your string or object");
        strapi.log.info("Yayy!, audit middleware rocks!");
    },
};