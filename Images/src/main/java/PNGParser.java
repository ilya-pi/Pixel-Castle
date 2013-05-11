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

    public static Gson gson = new GsonBuilder().create();
    public static Configuration config;

    public static class ImageData {
        private final int height;
        private final int width;
        private final String name;
        private final List<Integer> pixels;

        public ImageData(int height, int width, String name, List<Integer> pixels) {
            this.height = height;
            this.width = width;
            this.name = name;
            this.pixels = pixels;
        }
    }

    public static void main(String[] args) throws ConfigurationException, IOException {
        config = new PropertiesConfiguration("config.properties");
        String[] imageFolders = config.getStringArray("images.resource.folders");
        String extension = config.getString("image.extension");
        String outputFolder = config.getString("images.resource.output.folder");
        for (String imageFolder : imageFolders) {
            System.out.println("=======================================");
            System.out.println("processing imageFolder = " + imageFolder);
            System.out.println("=======================================");
            File folder = new File("src/main/resources/" + imageFolder);
            File[] listOfFiles = folder.listFiles();
            if (listOfFiles != null) {
                Map<String, ImageData> imagesForJson = new HashMap<String, ImageData>();
                for (File file : listOfFiles) { //todo filter out non extension files
                    if (file.getName().endsWith(extension)) {
                        System.out.println("processing file = " + file.getName());
                        String name = FilenameUtils.removeExtension(file.getName());
                        ImageData imageData = parseImage(file, name);
                        imagesForJson.put(name, imageData);
                    } else {
                        System.out.println("!!!!!!!!!!!!!!!!!!");
                        System.out.println("sorted out file: " + file.getName());
                        System.out.println("!!!!!!!!!!!!!!!!!!");
                    }
                }
                String jsonString = gson.toJson(imagesForJson);
                FileUtils.writeStringToFile(new File(outputFolder + "/" + imageFolder + ".json"), jsonString);
            }
        }
    }

    private static ImageData parseImage(File file, String name) throws IOException {
        List<Integer> pixels = new ArrayList<Integer>(2000);
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
        return new ImageData(height, width, name, pixels);
    }
}
