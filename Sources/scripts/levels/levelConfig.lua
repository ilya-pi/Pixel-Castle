module(..., package.seeall)

screens = {
    {
        screenNumber = 1,
        levels = {
            {
                file = "level1.json",
                bulletSpeed = 750,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level2.json",
                bulletSpeed = 850,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level3.json",
                bulletSpeed = 850,
                maxWindForce = 3,
                minScaleFactor = 0.5
            },
            {
                file = "level4.json",
                bulletSpeed = 850,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level5.json",
                bulletSpeed = 850,
                maxWindForce = 3,
                minScaleFactor = -1
            },
            {
                file = "level6.json",
                bulletSpeed = 850,
                maxWindForce = 5,
                minScaleFactor = -1
            }
        },
        bullets = {
            {
                bulletName = "7",
                count = 1,
                size = 20,
                dAngleInDegrees = 0
            },
            {
                bulletName = "11",
                count = 1,
                size = 30,
                dAngleInDegrees = 0

            },
            {
                bulletName = "3",
                count = 5,
                size = 10,
                dAngleInDegrees = 1

            }
        }
    }
}