import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PNGParser {

    public static final String castle1Name = "castle1";
    public static final String castle2Name = "castle2";
    public static final String levelName = "level";
    public static final String extension = ".png";

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

        public LevelData(int levelWidth, int levelHeight, CastleData castle1, CastleData castle2, String levelName) {
            this.levelWidth = levelWidth;
            this.levelHeight = levelHeight;
            this.castle1 = castle1;
            this.castle2 = castle2;
            this.levelName = levelName;
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

    public static void main(String[] args) throws ConfigurationException, IOException {
        config = new PropertiesConfiguration("config.properties");
        String[] imageFolders = config.getStringArray("images.resource.folders");
        String outputFolder = config.getString("images.resource.output.folder");
        for (String imageFolder : imageFolders) {
            System.out.println("=======================================");
            System.out.println("processing level folder = " + imageFolder);
            System.out.println("=======================================");

            File levelFile = new File("src/main/resources/" + imageFolder + "/" + levelName + extension);
            CastleCoordinates coordinates = getCoordinates(levelFile);

            LevelData levelData;
            File castle1File = new File("src/main/resources/" + imageFolder + "/" + castle1Name + extension);
            File castle2File = new File("src/main/resources/" + imageFolder + "/" + castle2Name + extension);
            CastleData castle1Data = parseImage(castle1File, castle1Name, coordinates.castle1X, coordinates.castle1Y);
            CastleData castle2Data = parseImage(castle2File, castle2Name, coordinates.castle2X, coordinates.castle2Y);
            levelData = new LevelData(coordinates.levelWidth, coordinates.levelHeight, castle1Data, castle2Data, imageFolder);

            String jsonString = gson.toJson(levelData);
            FileUtils.writeStringToFile(new File(outputFolder + "/" + imageFolder + ".json"), jsonString);
        }
    }

    private static CastleCoordinates getCoordinates(File file) throws IOException {
        CastleCoordinates coordinates = new CastleCoordinates();
        BufferedImage image = ImageIO.read(file); //todo catch exceptions?
        int width = image.getWidth();
        int height = image.getHeight();
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                int rgb = image.getRGB(x, y);
                int alpha = (rgb >> 24) & 0xFF;
                int red =   (rgb >> 16) & 0xFF;
                int green = (rgb >>  8) & 0xFF;
                int blue =  (rgb      ) & 0xFF;

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

    private static void testRGB(BufferedImage image, int x, int y) {
        int rgb = image.getRGB(265, 275);
        int alpha = (rgb >> 24) & 0xFF;
        int red =   (rgb >> 16) & 0xFF;
        int green = (rgb >>  8) & 0xFF;
        int blue =  (rgb      ) & 0xFF;
        System.out.println("x=" + x + " y=" + y + " red = " + red + " green = " + green + " blue = " + blue + " alpha = " + alpha);
    }

    private static CastleData parseImage(File file, String name, int xCastle, int yCastle) throws IOException {
        List<Integer> pixels = new ArrayList<Integer>(100000);
        BufferedImage image = ImageIO.read(file); //todo catch exceptions?
        int width = image.getWidth();
        int height = image.getHeight();
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int rgb = image.getRGB(x, y);
                int alpha = (rgb >> 24) & 0xFF;
                int red =   (rgb >> 16) & 0xFF;
                int green = (rgb >>  8) & 0xFF;
                int blue =  (rgb      ) & 0xFF;
                pixels.add(red);
                pixels.add(green);
                pixels.add(blue);
                pixels.add(alpha);
            }
        }
        return new CastleData(height, width, xCastle, yCastle, name, pixels);
    }
}
