import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.io.FileUtils;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PNGParser {

    public static final String CASTLE_1_NAME = "castle1";
    public static final String CASTLE_2_NAME = "castle2";
    public static final String LEVEL_NAME = "level";
    public static final String EXTENSION = "png";

    public static final int spriteWidthPixels = 3;

    public static final Color TRANSPARENT_COLOR = new Color(0, 0, 0, 0);

    public static Gson gson = new GsonBuilder().create();
    public static Configuration config;

    public static class CastleData {
        private final int height;
        private final int width;
        private final String name;
        private final int x;
        private final int y;
        private final List<Integer> pixels;

        public CastleData(int height, int width, int x, int y, String name, List<Integer> pixels) {
            this.height = height;
            this.width = width;
            this.name = name;
            this.pixels = pixels;
            this.x = x;
            this.y = y;
        }
    }

    public static class LevelData {
        private final int levelWidth;
        private final int levelHeight;
        private final String levelName;
        private final CastleData castle1;
        private final CastleData castle2;
        private final CastleData level;


        public LevelData(int levelWidth, int levelHeight, CastleData castle1, CastleData castle2, CastleData level, String levelName) {
            this.levelWidth = levelWidth;
            this.levelHeight = levelHeight;
            this.castle1 = castle1;
            this.castle2 = castle2;
            this.levelName = levelName;
            this.level = level;
        }
    }

    public static class CastleCoordinates {
        int castle1X= -1;
        int castle1Y = -1;
        int castle2X = -1;
        int castle2Y = -1;
        int levelWidth = -1;
        int levelHeight = -1;
    }

    public static void main(String[] args) throws Exception {
        config = new PropertiesConfiguration("config.properties");
        String[] imageFolders = config.getStringArray("images.resource.level.folders");
        String outputFolder = config.getString("images.resource.output.folder");
        for (String imageFolder : imageFolders) {
            System.out.println("=======================================");
            System.out.println("processing level folder = " + imageFolder);
            System.out.println("=======================================");

            File levelFile = new File("src/main/resources/" + imageFolder + "/" + LEVEL_NAME + "." + EXTENSION);
            BufferedImage levelImage = ImageIO.read(levelFile);
            CastleCoordinates coordinates = getCoordinates(levelImage);
            levelImage.setRGB(coordinates.castle1X, coordinates.castle1Y, TRANSPARENT_COLOR.getRGB());
            levelImage.setRGB(coordinates.castle2X, coordinates.castle2Y, TRANSPARENT_COLOR.getRGB());

            File castle1File = new File("src/main/resources/" + imageFolder + "/" + CASTLE_1_NAME + "." + EXTENSION);
            BufferedImage castle1Image = ImageIO.read(castle1File);
            File castle2File = new File("src/main/resources/" + imageFolder + "/" + CASTLE_2_NAME + "." + EXTENSION);
            BufferedImage castle2Image = ImageIO.read(castle2File);

            Level.Castle castle1 = new Level.Castle(castle1Image.getWidth(), castle1Image.getHeight(), coordinates.castle1X, coordinates.castle1Y - castle1Image.getHeight() + 1);
            Level.Castle castle2 = new Level.Castle(castle2Image.getWidth(), castle2Image.getHeight(), coordinates.castle2X, coordinates.castle2Y - castle2Image.getHeight() + 1);
            BufferedImage merged = new BufferedImage(levelImage.getWidth(), levelImage.getHeight(), levelImage.getType());
            Graphics2D g2 = merged.createGraphics();
            g2.drawImage(levelImage, 0, 0, null);
            g2.drawImage(castle1Image, castle1.getX(), castle1.getY(), null);
            g2.drawImage(castle2Image, castle2.getX(), castle2.getY(), null);
            g2.dispose();

            File levelFolder = new File(outputFolder + "/" + imageFolder);
            FileUtils.forceMkdir(levelFolder);
            ImageIO.write(merged, EXTENSION, new File(levelFolder.getPath() + "/" + LEVEL_NAME + "." + EXTENSION));  // ignore returned boolean

            //generating pixels
            int width = merged.getWidth();
            int height = merged.getHeight();
            int pixelsSkipFromTop = -1;
            List<Level.Pixel[]> rows = new ArrayList<Level.Pixel[]>(height);
            for (int y = 0; y < height; y++) {

                Level.Pixel[] row = new Level.Pixel[width];
                for (int x = 0; x < width; x++) {
                    RGBA rgb = getRGB(merged, x, y);
                    int alpha = rgb.a;
                    int red =   rgb.r;
                    int green = rgb.g;
                    int blue =  rgb.b;

                    if (alpha != 0) {
                        if (pixelsSkipFromTop == -1) {
                            pixelsSkipFromTop = y + 1;
                        }
                        int[] rgba = {red, green, blue, alpha};
                        Level.Pixel pixel = new Level.Pixel(rgba, 3);
                        row[x] = pixel;
                    } else {
                        row[x] = null; //to be sure ))
                    }
                }
                if (pixelsSkipFromTop != -1) {
                    rows.add(row);
                } else {
                    rows.add(null);
                }
            }

            Level.Pixel[][] pixels = rows.toArray(new Level.Pixel[rows.size()][]);

            Level levelForJson = new Level(pixels, height, width, imageFolder, castle1, castle2, pixelsSkipFromTop);
            String pixelsJson = gson.toJson(levelForJson);
            FileUtils.writeStringToFile(new File(outputFolder + "/" + imageFolder + ".json"), pixelsJson);
        }

        String bulletsFolder = config.getString("images.resource.bullet.folder");
        System.out.println("=======================================");
        System.out.println("processing bullet folder = " + bulletsFolder);
        System.out.println("=======================================");
        File bulletsFolderFile = new File("src/main/resources/" + bulletsFolder);
        File[] listOfFiles = bulletsFolderFile.listFiles();
        Map<String, Integer[][]> bulletsMap = new HashMap<String, Integer[][]>();
        if (listOfFiles != null) {
            for (File file : listOfFiles) {
                if (file.getName().endsWith(EXTENSION)) {
                    System.out.println("processing bullet file:  " + file.getName());
                    BufferedImage bulletImage = ImageIO.read(file);
                    int width = bulletImage.getWidth();
                    int height = bulletImage.getHeight();
                    Integer[][] bulletArray = new Integer[width][height];
                    for (int x = 0; x < width; x++) {
                        for (int y = 0; y < height; y++) {
                            RGBA rgb = getRGB(bulletImage, x, y);
                            int alpha = rgb.a;
                            int red =   rgb.r;
                            int green = rgb.g;
                            int blue =  rgb.b;
                            int health = 0;
                            if (red == 255 && green == 255 && blue == 255 && alpha == 255) {
                                health = 2;
                            } else if (red == 0 && green == 0 && blue == 0 && alpha == 255) {
                                health = 1;
                            }
                            bulletArray[x][y] = health;
                        }
                    }
                    bulletsMap.put(file.getName().replaceAll("." + EXTENSION, ""), bulletArray);
                }
            }
            String bulletsJson = gson.toJson(bulletsMap);
            FileUtils.writeStringToFile(new File(outputFolder + "/bullets.json"), bulletsJson);
        }

    }

    private static CastleCoordinates getCoordinates(BufferedImage image) throws IOException {
        CastleCoordinates coordinates = new CastleCoordinates();
        int width = image.getWidth();
        int height = image.getHeight();
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                RGBA rgb = getRGB(image, x, y);
                int alpha = rgb.a;
                int red =   rgb.r;
                int green = rgb.g;
                int blue =  rgb.b;

                if (red == 255 && green == 0 && blue == 255 && alpha == 255) {
                    System.out.println("hey!");
                    if (coordinates.castle1X == -1) {
                        coordinates.castle1X = x;
                        coordinates.castle1Y = y;
                        System.out.println("found first castle with coordinates: x=" + x + " y=" + y);
                    } else if (coordinates.castle2X == -1) {
                        coordinates.castle2X = x;
                        coordinates.castle2Y = y;
                        System.out.println("found second castle with coordinates: x=" + x + " y=" + y);
                    } else {
                        throw new IllegalStateException("there should be only two placeholders for castles. Fount third at x = '" + x +  "', y= '" + y + "'");
                    }
                }
            }
        }

        if (coordinates.castle1X == -1 || coordinates.castle2X == -1 || coordinates.castle1Y == -1 || coordinates.castle2Y == -1) {
            throw new IllegalStateException("cannot find coordinates for two castles");
        }
        coordinates.levelHeight = height;
        coordinates.levelWidth = width;
        return coordinates;
    }

    private static RGBA getRGB(BufferedImage image, int x, int y) {
        int rgb = image.getRGB(x, y);
        int alpha = (rgb >> 24) & 0xFF;
        int red =   (rgb >> 16) & 0xFF;
        int green = (rgb >>  8) & 0xFF;
        int blue =  (rgb      ) & 0xFF;
        return new RGBA(red, green, blue, alpha);
    }
}
