#!/bin/bash
mongoimport -d iot -c sys.authority --file ./sys.authority.json
mongoimport -d iot -c tenant.role --file ./tenant.role.json
mongoimport -d iot -c tenant.staff_roles --file ./tenant.staff_roles.json
