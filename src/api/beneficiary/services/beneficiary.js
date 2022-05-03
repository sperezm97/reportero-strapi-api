'use strict';

/**
 * beneficiary service.
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::beneficiary.beneficiary');
