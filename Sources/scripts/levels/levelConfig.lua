module(..., package.seeall)

screens = {
    {
        screenNumber = 1,
        levels = {
            {
                file = "level1.json",
                bulletImpulse = 77000,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level2.json",
                bulletImpulse = 83000,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level3.json",
                bulletImpulse = 91000,
                maxWindForce = 3,
                minScaleFactor = 0.5
            },
            {
                file = "level4.json",
                bulletImpulse = 91000,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level5.json",
                bulletImpulse = 69000,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level6.json",
                bulletImpulse = 70000,
                maxWindForce = 5,
                minScaleFactor = -1
            }
        },
        bullets = {
            {
                bulletName = "7",
                count = 1,
                dAngleInDegrees = 0
            },
            {
                bulletName = "11",
                count = 1,
                dAngleInDegrees = 0

            },
            {
                bulletName = "3",
                count = 5,
                dAngleInDegrees = 10

            }
        }
    }
}