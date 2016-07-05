package org.hsweb.platform.workflow.modeler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.activiti.engine.IdentityService;
import org.activiti.engine.RepositoryService;
import org.activiti.engine.repository.Model;
import org.activiti.explorer.*;
import org.activiti.explorer.navigation.NavigationFragmentChangeListener;
import org.activiti.explorer.navigation.NavigatorManager;
import org.activiti.explorer.ui.MainWindow;
import org.activiti.explorer.ui.content.AttachmentRendererManager;
import org.activiti.explorer.ui.form.*;
import org.activiti.explorer.ui.login.DefaultLoginHandler;
import org.activiti.explorer.ui.login.LoginHandler;
import org.activiti.explorer.ui.management.deployment.DeploymentFilterFactory;
import org.activiti.explorer.ui.process.ProcessDefinitionFilterFactory;
import org.activiti.explorer.ui.variable.VariableRendererManager;
import org.activiti.workflow.simple.converter.WorkflowDefinitionConversionFactory;
import org.activiti.workflow.simple.converter.json.SimpleWorkflowJsonConverter;
import org.apache.commons.io.IOUtils;
import org.hsweb.commons.file.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;
import org.springframework.context.support.ResourceBundleMessageSource;

import javax.annotation.PostConstruct;
import java.io.InputStream;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * Created by zhouhao on 16-4-30.
 */
@Configuration
@ComponentScan(basePackages = {"org.hsweb.web.workflow"})
public class ActivityModelerAutoConfigure {

    @Autowired
    private RepositoryService repositoryService;

    @PostConstruct
    protected void initModelData() throws Exception {
       // createModelData("测试流程模型", "This is a demo model", "test.model.json");
    }

    @Bean
    public NavigatorManager navigatorManager() {
        return new NavigatorManager();
    }

    @Bean
    public AttachmentRendererManager attachmentRendererManager() {
        return new AttachmentRendererManager();
    }

    @Bean
    public FormPropertyRendererManager formPropertyRendererManager() {
        FormPropertyRendererManager formPropertyRendererManager = new FormPropertyRendererManager();
        formPropertyRendererManager.setNoTypePropertyRenderer(new StringFormPropertyRenderer());
        formPropertyRendererManager.setPropertyRenderers(Arrays.asList(
                new StringFormPropertyRenderer(),
                new EnumFormPropertyRenderer(),
                new LongFormPropertyRenderer(),
                new DoubleFormPropertyRenderer(),
                new DateFormPropertyRenderer(),
                new UserFormPropertyRenderer(),
                new BooleanFormPropertyRenderer(),
                new ProcessDefinitionFormPropertyRenderer(),
                new MonthFormPropertyRenderer()
        ));
        return formPropertyRendererManager;
    }

    protected void createModelData(String name, String description, String jsonFile) throws Exception {
        List<Model> modelList = repositoryService.createModelQuery().modelName("Demo model").list();

        if (modelList == null || modelList.isEmpty()) {

            Model model = repositoryService.newModel();
            model.setName(name);

            ObjectNode modelObjectNode = new ObjectMapper().createObjectNode();
            modelObjectNode.put("name", name);
            modelObjectNode.put("description", description);
            model.setMetaInfo(modelObjectNode.toString());

            repositoryService.saveModel(model);

            InputStream svgStream = FileUtils.getResourceAsStream("test.svg");
            repositoryService.addModelEditorSourceExtra(model.getId(), IOUtils.toByteArray(svgStream));

            InputStream editorJsonStream = FileUtils.getResourceAsStream(jsonFile);
            repositoryService.addModelEditorSource(model.getId(), IOUtils.toByteArray(editorJsonStream));

        }
    }

    @Bean
    public VariableRendererManager variableRendererManager() {
        return new VariableRendererManager();
    }

    @Bean
    public ComponentFactories componentFactories() {
        ComponentFactories componentFactories = new ComponentFactories();
        componentFactories.setEnvironment(Environments.ACTIVITI);
        return componentFactories;
    }

    @Bean
    public ProcessDefinitionFilterFactory processDefinitionFilterFactory() {
        return new ProcessDefinitionFilterFactory();
    }

    @Bean
    public DeploymentFilterFactory deploymentFilterFactory() {
        return new DeploymentFilterFactory();
    }

    @Bean
    @Scope("session")
    public NavigationFragmentChangeListener navigationFragmentChangeListener() {
        NavigationFragmentChangeListener navigationFragmentChangeListener = new NavigationFragmentChangeListener();
        navigationFragmentChangeListener.setNavigatorManager(navigatorManager());
        return navigationFragmentChangeListener;
    }

    @Bean
    public ResourceBundleMessageSource resourceBundleMessageSource() {
        ResourceBundleMessageSource resourceBundleMessageSource = new ResourceBundleMessageSource();
        resourceBundleMessageSource.setBasename("messages");
        return resourceBundleMessageSource;
    }

    @Bean
    @Scope("session")
    public I18nManager i18nManager() {
        I18nManager i18nManager = new I18nManager();
        i18nManager.setLocale(Locale.CHINA);
        i18nManager.setMessageSource(resourceBundleMessageSource());
        return i18nManager;
    }

    @Bean
    @Scope("session")
    public MainWindow mainWindow() {
        MainWindow mainWindow = new MainWindow();
        mainWindow.setNavigationFragmentChangeListener(navigationFragmentChangeListener());
        return mainWindow;
    }

    @Bean
    @Scope("session")
    public NotificationManager notificationManager() {
        NotificationManager notificationManager = new NotificationManager();
        notificationManager.setMainWindow(mainWindow());
        return notificationManager;
    }

    @Bean
    @Scope("session")
    public ViewManagerFactoryBean viewManagerFactoryBean() {
        ViewManagerFactoryBean viewManagerFactoryBean = new ViewManagerFactoryBean();
        viewManagerFactoryBean.setMainWindow(mainWindow());
        viewManagerFactoryBean.setEnvironment(Environments.ACTIVITI);
        return viewManagerFactoryBean;
    }

    @Bean
    public WorkflowDefinitionConversionFactory workflowDefinitionConversionFactory() {
        return new WorkflowDefinitionConversionFactory();
    }

    @Bean
    @Scope("session")
    public ExplorerApp explorerApp(IdentityService identityService) throws Exception {
        ExplorerApp app = new ExplorerApp();
        app.setUseJavascriptDiagram(true);
        app.setEnvironment("alfresco");
        app.setI18nManager(i18nManager());
        app.setMainWindow(mainWindow());
        app.setNotificationManager(notificationManager());
        app.setAttachmentRendererManager(attachmentRendererManager());
        app.setFormPropertyRendererManager(formPropertyRendererManager());
        app.setVariableRendererManager(variableRendererManager());
        app.setApplicationMainWindow(mainWindow());
        app.setComponentFactories(componentFactories());
        app.setWorkflowDefinitionConversionFactory(workflowDefinitionConversionFactory());
        app.setLoginHandler(loginHandler(identityService));
        app.setSimpleWorkflowJsonConverter(simpleWorkflowJsonConverter());
        app.setViewManager((viewManagerFactoryBean().getObject()));
        return app;
    }

    @Bean
    public SimpleWorkflowJsonConverter simpleWorkflowJsonConverter() {
        return new SimpleWorkflowJsonConverter();
    }

    @Bean
    public LoginHandler loginHandler(IdentityService identityService) {
        DefaultLoginHandler loginHandler = new DefaultLoginHandler();
        loginHandler.setIdentityService(identityService);
        return loginHandler;
    }
//
//    @Bean
//    public ExplorerApplicationServlet explorerApplicationServlet() {
//        ExplorerApplicationServlet explorerApplicationServlet = new ExplorerApplicationServlet();
//        return explorerApplicationServlet;
//    }
//
//    @Bean
//    public ServletRegistrationBean servletRegistrationBean() {
//        Map<String, String> param = new HashMap<>();
//        ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean(explorerApplicationServlet(), "/VAADIN/*");
//        servletRegistrationBean.setInitParameters(param);
//        return servletRegistrationBean;
//    }

//    @Bean
//    public FilterRegistrationBean filterRegistrationBean() {
//        FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean();
//        filterRegistrationBean.setUrlPatterns(Arrays.asList("/*"));
//        filterRegistrationBean.setFilter(new ExplorerFilter());
//        return filterRegistrationBean;// ServletName默认值为首字母小写，即myServlet
//    }

//    @Bean
//    public ServletRegistrationBean servletRegistrationBean2(WebApplicationContext context) {
//        AnnotationConfigWebApplicationContext dispatcherServletConfiguration = new AnnotationConfigWebApplicationContext();
//        dispatcherServletConfiguration.setParent(context);
//        dispatcherServletConfiguration.register(ActivityConfig.class);
//        ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean();
//        DispatcherServlet dispatcherServlet = new DispatcherServlet();
//        dispatcherServlet.setApplicationContext(dispatcherServletConfiguration);
//        servletRegistrationBean.setServlet(dispatcherServlet);
//        servletRegistrationBean.setLoadOnStartup(1);
//        servletRegistrationBean.setName("activity");
//        servletRegistrationBean.addUrlMappings("/service/*");
//        return servletRegistrationBean;
//    }

}
