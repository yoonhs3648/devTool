package yoon.hyeon.sang.sap;

import com.sap.conn.jco.ext.DestinationDataEventListener;
import com.sap.conn.jco.ext.DestinationDataProvider;

import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

public class MyDestinationDataProvider implements DestinationDataProvider {

    private static MyDestinationDataProvider instance = new MyDestinationDataProvider();
    private Map<String, Properties> destinations = new HashMap<>();
    private DestinationDataEventListener eventListener;

    public static MyDestinationDataProvider getInstance() {
        return instance;
    }

    @Override
    public Properties getDestinationProperties(String destinationName) {
        return destinations.get(destinationName);
    }

    @Override
    public void setDestinationDataEventListener(DestinationDataEventListener listener) {
        this.eventListener = listener;
    }

    @Override
    public boolean supportsEvents() {
        return true;
    }

    public void addDestination(String name, Properties props) {
        destinations.put(name, props);

        if (eventListener != null) {
            eventListener.updated(name);
        }
    }

    public Set<String> getAllKeys() {
        return destinations.keySet();
    }

    public void removeDestination(String name) {
        destinations.remove(name);
    }
}
